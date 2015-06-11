package eu.inn.wssign.controller;

import java.io.ByteArrayInputStream;
import java.io.ByteArrayOutputStream;
import java.io.File;
import java.io.FileInputStream;
import java.io.IOException;
import java.io.UnsupportedEncodingException;
import java.security.cert.CertificateFactory;
import java.security.cert.X509Certificate;
import java.util.ArrayList;
import java.util.Collection;
import java.util.Date;
import java.util.List;
import java.util.UUID;

import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;

import org.apache.commons.codec.binary.Base64;
import org.apache.commons.io.FileUtils;
import org.apache.commons.io.IOUtils;
import org.apache.commons.lang.StringUtils;
import org.apache.log4j.Level;
import org.apache.log4j.Logger;
import org.codehaus.jackson.map.ObjectMapper;
import org.json.simple.JSONArray;
import org.json.simple.JSONObject;
import org.json.simple.parser.JSONParser;
//import org.slf4j.Logger;
//import org.slf4j.LoggerFactory;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.http.HttpStatus;
import org.springframework.stereotype.Controller;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RequestMethod;
import org.springframework.web.bind.annotation.RequestParam;
import org.springframework.web.bind.annotation.ResponseBody;
import org.springframework.web.bind.annotation.ResponseStatus;
import org.springframework.web.multipart.MultipartFile;
import org.springframework.web.multipart.MultipartHttpServletRequest;

import com.lowagie.text.pdf.PdfReader;
import com.lowagie.text.pdf.PdfStamper;

import eu.inn.sign.InnoBaseSign;
import eu.inn.sign.datalayer.FileObject;
import eu.inn.sign.pdf.document.PdfBinding;
import eu.inn.sign.pdf.document.PdfPageInfo;
import eu.inn.sign.pdf.render.IPdfRenderedListener;
import eu.inn.sign.signature.ParsedSignatureField;
import eu.inn.sign.signature.SignatureField;
import eu.inn.sign.signature.SignatureParameters;
import eu.inn.sign.web.util.JsonSerializer;
import eu.inn.wssign.InnoSignerFactory;
import eu.inn.wssign.controller.DocumentSignController.ResourceNotFoundException;
import eu.inn.wssign.controller.utils.AuditLogger;

/**
 * Handles requests for the signature web api.
 */
@Controller
@RequestMapping("/apiV2")
@SuppressWarnings("unchecked")
public class ApiControllerV2 {	
	
	@Autowired
	private InnoSignerFactory signerFactory;

	@RequestMapping(value = "/getBindingInfo")
	public @ResponseBody byte[] getBindingInfo(@RequestParam String uuid) {
		Date d1 = new Date();
		JSONObject ret = new JSONObject();
		try {
			PdfBinding bind = signerFactory.getSigner(uuid).getBindingInfo();
			ret.put("hash", bind.getHash());
			ret.put("count", bind.getCount());
			ret.put("offset", bind.getOffset());
			ret.put("alg", bind.getAlgorithm());

		} catch (Exception e) {
			logger.error("Internal Server Error - " + e.getMessage(), e);
			ret.put("errorMessage", "Cannot get binding. " + e.getMessage());
		}
		Date d2 = new Date();
		timing.debug("getBindingInfo "+uuid+" : "+(d2.getTime()-d1.getTime())+"ms");
		return ret.toJSONString().getBytes();

	}

	private static final Logger logger = Logger.getLogger(ApiControllerV2.class);
	private static final Logger timing = Logger.getLogger("TIMING");

	public ApiControllerV2() throws IOException {

	}

	@RequestMapping(value = "/signFEA", method = RequestMethod.POST)
	public @ResponseBody String signFEA(@RequestParam String uuid, @RequestParam SignatureParameters signatureParameters) {
		Date d1 = new Date();
		JSONObject ret = new JSONObject();

		try {
			signerFactory.getSigner(uuid).sign(signatureParameters, null);
			ret.put("uuid", uuid.toString());
		} catch (Exception e) {
			logger.error("Internal Server Error - " + e.getMessage(), e);
			ret.put("errorMessage", "Cannot sign document. " + e.getMessage());
		}
		Date d2 = new Date();
		timing.debug("signFEA "+uuid+" : "+(d2.getTime()-d1.getTime())+"ms");
		return ret.toJSONString();
	}

	@RequestMapping(value = "/undoLastSign", method = RequestMethod.POST)
	public @ResponseBody String undoLastSign(@RequestParam String uuid, @RequestParam(defaultValue="false") String searchForSignature) {
		Date d1 = new Date();
		JSONObject ret = new JSONObject();
		try {
			logger.debug("Called undoLastSign ");
			logger.info("Document to sign uuid: " + uuid);
			boolean done = signerFactory.getSigner(uuid).undo(Boolean.parseBoolean(searchForSignature));
			if (done)
				ret.put("uuid", uuid);
		} catch (Exception e) {
			logger.error("Internal Server Error - " + e.getMessage(), e);
			ret.put("errorMessage", "Cannot undo Last Sign. " + e.getMessage());
		}
		Date d2 = new Date();
		timing.debug("undoLastSign "+uuid+" : "+(d2.getTime()-d1.getTime())+"ms");
		return ret.toJSONString();
	}

	@RequestMapping(value = "/signLocalStep1", method = RequestMethod.POST)
	public @ResponseBody String signLocalStep1(@RequestParam String uuid, @RequestParam String base64Cert,
			@RequestParam SignatureParameters signatureParameters) {
		Date d1 = new Date();
		JSONObject ret = new JSONObject();
		try {
			CertificateFactory cf = CertificateFactory.getInstance("X509");
			ByteArrayInputStream bais = new ByteArrayInputStream(Base64.decodeBase64(base64Cert.getBytes("UTF-8")));
			X509Certificate cert = (X509Certificate) cf.generateCertificate(bais);
			try {
				bais.close();
			} catch (Exception ex) {
			}
			byte[] toBeSigned = signerFactory.getSigner(uuid).getToBeSignedData(signatureParameters, cert);
			
			ret.put("signData", new String(Base64.encodeBase64(toBeSigned), "UTF-8"));			
			if (!signerFactory.getSigner(uuid).getSignFields().get(signatureParameters.getName()).isVisible()) //omit if signature is invisible
				signatureParameters.setOriginal(new byte[0]);
			ret.put("signatureParameters", JsonSerializer.writeSignatureParameters(signatureParameters));
		} catch (Exception e) {
			ret.put("errorMessage", e.getMessage());
		}
		Date d2 = new Date();
		timing.debug("signLocalStep1 "+uuid+" : "+(d2.getTime()-d1.getTime())+"ms");
		return ret.toJSONString();
	}

	@RequestMapping(value = "/signLocalStep2", method = RequestMethod.POST)
	public @ResponseBody String signLocalStep2(@RequestParam String uuid, @RequestParam String base64Digest) {
		Date d1 = new Date();
		JSONObject ret = new JSONObject();
		try {
			signerFactory.getSigner(uuid).sign(null, Base64.decodeBase64(base64Digest.getBytes("UTF-8")));
			ret.put("uuid", uuid.toString());
		} catch (Exception e) {
			ret.put("errorMessage", e.getMessage());
		}
		Date d2 = new Date();
		timing.debug("signLocalStep2 "+uuid+" : "+(d2.getTime()-d1.getTime())+"ms");
		return ret.toJSONString();
	}

	@RequestMapping(value = "/upload", method = RequestMethod.POST)
	public @ResponseBody void upload(HttpServletRequest request, HttpServletResponse response) {
		Date d1 = new Date();
		JSONObject ret = new JSONObject();
		try {
			MultipartHttpServletRequest multipartRequest = (MultipartHttpServletRequest) request;
			MultipartFile fileToSignFile = multipartRequest.getFile(multipartRequest.getFileNames().next());
			FileObject toStore = new FileObject(fileToSignFile.getBytes(), fileToSignFile.getOriginalFilename());
			InnoBaseSign<UUID> created = signerFactory.createSigner();
			created.importDocument(toStore);
			UUID generated = created.getUuid();
			signerFactory.putSigner(created);
			logger.info("Upload Document uuid: " + generated.toString());
			ret.put("uuid", generated.toString());
		} catch (Exception e) {
			logger.error("Internal Server Error - " + e.getMessage(), e);
			ret.put("errorMessage", "Cannot upload document. " + e.getMessage());
		}
		
		try {
			response.getOutputStream().print(ret.toJSONString());
		} catch (IOException e) {
			e.printStackTrace();
		}
		Date d2 = new Date();
		timing.debug("upload : "+(d2.getTime()-d1.getTime())+"ms");
	}


	@RequestMapping(value = "/getTotalPages")
	public @ResponseBody byte[] getPdfInfo(@RequestParam String uuid) {
		Date d1 = new Date();
		JSONObject ret = new JSONObject();
		try {
			ret.put("pages", signerFactory.getSigner(uuid).getTotalPages());
		} catch (Exception e) {
			logger.error("Internal Server Error - " + e.getMessage(), e);
			ret.put("errorMessage", "Cannot get signatures. " + e.getMessage());
		}
		Date d2 = new Date();
		timing.debug("getTotalPages "+uuid+" : "+(d2.getTime()-d1.getTime())+"ms");
		return ret.toJSONString().getBytes();
	}

	@RequestMapping(value = "/getPageInfo")
	public @ResponseBody byte[] getPdfInfo(@RequestParam String uuid, @RequestParam int page) {
		Date d1 = new Date();
		JSONObject ret = new JSONObject();
		try {
			PdfPageInfo pInfo = signerFactory.getSigner(uuid).getPageInfo(page);
			ret.put("realHeightPage", pInfo.getHeight());
			ret.put("realWidthPage", pInfo.getWidth());
		} catch (Exception e) {
			logger.error("Internal Server Error - " + e.getMessage(), e);
			ret.put("errorMessage", "Cannot get signatures. " + e.getMessage());
		}
		Date d2 = new Date();
		timing.debug("getPageInfo "+uuid+" : "+(d2.getTime()-d1.getTime())+"ms");
		return ret.toJSONString().getBytes();
	}

	
	@RequestMapping(value = "/getSignatures", consumes = "*/*; charset=utf-8", method = RequestMethod.POST)
	public @ResponseBody byte[] getSignatures(@RequestParam String uuid,
			@RequestParam(defaultValue = "true") boolean skipTextAnalysis,
			@RequestParam(defaultValue = "§dsig") String prefix, @RequestParam(required = false) String suffix) {
		Date d1 = new Date();
		JSONObject ret = new JSONObject();
		try {
			Collection<SignatureField> sigs = signerFactory.getSigner(uuid)
					.getSignFields(!skipTextAnalysis, prefix, suffix).values();
			ret.put("signatures", JsonSerializer.writeSignatureFields(sigs));

		} catch (Exception e) {
			logger.error("Internal Server Error - " + e.getMessage(), e);
			ret.put("errorMessage", "Cannot get signatures. " + e.getMessage());
		}
		Date d2 = new Date();
		timing.debug("getSignatures "+uuid+" : "+(d2.getTime()-d1.getTime())+"ms");
		return ret.toJSONString().getBytes();

	}

	@RequestMapping(value = "/addSignatureFields", method = RequestMethod.POST)
	public @ResponseBody byte[] addSignatureFields(final @RequestParam String uuid, String signatures,
			@RequestParam(defaultValue = "true") boolean throwsOnError) {
		Date d1 = new Date();
		JSONObject ret = new JSONObject();
		try {
			List<SignatureField> fieldToAdd = JsonSerializer.readSignatureFields(signatures);
//			new ArrayList<SignatureField>();
//			JSONParser parser = new JSONParser();
//			JSONObject config = (JSONObject) parser.parse(signatures);
//			JSONArray array = (JSONArray) config.get("signatures");
//			for (Object signObj : array) {
//				JSONObject signature = (JSONObject) signObj;
//				float height = Float.parseFloat(signature.get("height").toString());
//				float width = Float.parseFloat(signature.get("width").toString());
//				SignatureField s = new SignatureField();
//				s.setName(signature.get("name").toString());
//				if (height > 0 && width > 0) {
//					s.setPage(Integer.parseInt(signature.get("page").toString()));
//					s.setLeft(Float.parseFloat(signature.get("left").toString()));
//					s.setTop(Float.parseFloat(signature.get("top").toString()));
//					s.setHeight(height);
//					s.setWidth(width);
//				}
//				fieldToAdd.add(s);
//			}
			signerFactory.getSigner(uuid).createSignatureFields(fieldToAdd, throwsOnError);
			ret.put("uuid", uuid);
		} catch (Exception ex) {
			logger.error("Internal Server Error - " + ex.getMessage(), ex);
			ret.put("errorMessage", "Cannot prepare document. " + ex.getMessage());
		}
		Date d2 = new Date();
		timing.debug("addSignatureFields "+uuid+" : "+(d2.getTime()-d1.getTime())+"ms");
		return ret.toJSONString().getBytes();
	}

	@RequestMapping(value = "/download", method = RequestMethod.GET)
	public @ResponseBody byte[] download(final @RequestParam String uuid, HttpServletResponse response,
			HttpServletRequest request) {
		Date d1 = new Date();
		try {
			FileObject f = signerFactory.getSigner(uuid).getFileObject();
			if (f == null)
				throw new Exception("Document " + uuid + " does not exists");
			AuditLogger.LOG(
					Level.INFO,
					String.format("Downloading file with uuid %s from remote address %s:%s with user %s", uuid,
							request.getRemoteAddr(), request.getRemotePort(), request.getRemoteUser()));
			response.setHeader("Content-Disposition", "attachment; filename=\"" + f.getName() + "\"");
			response.setContentLength(f.getData().length);
			response.setContentType("application/octet-stream");
			response.getOutputStream().write(f.getData());
			response.getOutputStream().flush();
			return null;
		} catch (Exception e) {
			logger.error("Internal Server Error - " + e.getMessage());
			throw new ResourceNotFoundException();
		}
		finally {
			Date d2 = new Date();
			timing.debug("download "+uuid+" : "+(d2.getTime()-d1.getTime())+"ms");
		}
	}

	@RequestMapping(value = "/exists", method = RequestMethod.GET)
	public @ResponseBody byte[] exists(final @RequestParam String uuid) throws IOException {
		Date d1 = new Date();
		JSONObject ret = new JSONObject();
		try {
			FileObject fo = signerFactory.getSigner(uuid).getFileObject();
			ret.put("exists", fo != null);
			ret.put("name", fo != null ? fo.getName() : "");
			ret.put("uuid", uuid);
		} catch (Exception ex) {
			ex.printStackTrace();
			ret.put("exists", false);
			ret.put("name", "");
			ret.put("uuid", uuid);
		}
		Date d2 = new Date();
		timing.debug("exists "+uuid+" : "+(d2.getTime()-d1.getTime())+"ms");
		return ret.toJSONString().getBytes();
	}

	@RequestMapping(value = "/getFileBytes", method = RequestMethod.GET)
	public @ResponseBody void getFileBytes(final @RequestParam String uuid, HttpServletResponse response)
			throws IOException {
		Date d1 = new Date();
		try {
//			byte[] data = signerFactory.getSigner(uuid).getFileObject().getData();
			File f = signerFactory.getSigner(uuid).getFileObject().getFile();
			response.setContentType("application/pdf");
			response.setContentLength((int)f.length());
			response.setHeader("Content-Disposition", "attachment; filename=\"" + uuid + ".pdf\"");
			response.flushBuffer();
			IOUtils.copy(new FileInputStream(f), response.getOutputStream());
		} catch (Exception ex) {
			throw new ResourceNotFoundException();
		}
		finally {
			Date d2 = new Date();
			timing.debug("getFileBytes "+uuid+" : "+(d2.getTime()-d1.getTime())+"ms");
		}
	}
	
	@RequestMapping(value = "/getFileFlat", method = RequestMethod.GET)
	public @ResponseBody byte[] getFileFlat(final @RequestParam String uuid, HttpServletResponse response)
			throws IOException {
		JSONObject ret = new JSONObject();
		try {
			byte[] data = signerFactory.getSigner(uuid).getFileObject().getData();
			ByteArrayOutputStream outputStream = new ByteArrayOutputStream();
			PdfReader reader = new PdfReader(data);
			PdfStamper stamp1 = new PdfStamper(reader, outputStream, '\0');
			stamp1.setFormFlattening(true);
			stamp1.close();
			reader.close();
			ret.put("documentFlat",org.apache.xml.security.utils.Base64.encode(outputStream.toByteArray()));
			
		} catch (Exception ex) {
			throw new ResourceNotFoundException();
		}
		return ret.toJSONString().getBytes();
	}

	private class bean{
		Float width=0f;
		Float heigth=0f;
		int totalPages=0;
	}
	
	@RequestMapping(value = "/getImage", method = RequestMethod.GET)
	public @ResponseBody String getPageAsImage(final @RequestParam String uuid, int page, HttpServletResponse res) {
		Date d1 = new Date();
		if (page <= 0)
			throw new ResourceNotFoundException();
		try {
			System.err.println("Generating page " + page);
			final JSONObject pageImage = new JSONObject();
			InnoBaseSign<UUID> s = signerFactory.getSigner(uuid);
			final bean b = new bean();
			s.getPageImage(page, 1, new IPdfRenderedListener() {
				@Override
				public void onDocumentLoaded(int totalPages, Object[] addictionalData) {
					// TODO Auto-generated method stub
					b.totalPages=totalPages;
					try {
						b.width=Float.parseFloat(addictionalData[0].toString());
						b.heigth=Float.parseFloat(addictionalData[1].toString());
					}catch (Exception e)
					{
						e.printStackTrace();
					}
				}				
				
				@Override
				public void onRendered(int page, double scale, byte[] image) {
					try {
						pageImage.put("imageb64", new String(Base64.encodeBase64(image), "UTF-8"));
					} catch (UnsupportedEncodingException e) {
						throw new RuntimeException(e);
					}
				}
			});
			if (b.width==0)
				b.width=s.getPageInfo(page).getWidth();
			pageImage.put("width", b.width.intValue());
			pageImage.put("height", b.heigth.intValue());
			pageImage.put("totalPages", b.totalPages);
			return pageImage.toJSONString();
		} catch (Exception e) {
			logger.error("Internal Server Error - " + e.getMessage());
			e.printStackTrace();
			throw new ResourceNotFoundException();
		}
		finally {
			Date d2 = new Date();
			timing.debug("getImage "+uuid+" : "+(d2.getTime()-d1.getTime())+"ms");
		}
	}
	
	@SuppressWarnings("serial")
	@ResponseStatus(value = HttpStatus.NOT_FOUND)
	public class ResourceNotFoundException extends RuntimeException {

	}

}
