package eu.inn.wssign.controller;

import java.io.ByteArrayInputStream;
import java.io.ByteArrayOutputStream;
import java.io.File;
import java.io.IOException;
import java.security.Security;
import java.security.cert.CertificateFactory;
import java.security.cert.X509Certificate;
import java.util.ArrayList;
import java.util.Date;
import java.util.LinkedList;
import java.util.List;
import java.util.Map;
import java.util.UUID;

import javax.annotation.PostConstruct;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;

import org.apache.commons.codec.binary.Base64;
import org.apache.commons.io.FileUtils;
import org.apache.commons.io.IOUtils;
import org.apache.commons.lang.StringUtils;
import org.apache.log4j.Level;
import org.apache.log4j.Logger;
import org.bouncycastle.jce.provider.BouncyCastleProvider;
import org.json.simple.JSONArray;
import org.json.simple.JSONObject;
import org.json.simple.parser.JSONParser;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.context.MessageSource;
import org.springframework.http.HttpStatus;
import org.springframework.stereotype.Controller;
import org.springframework.ui.Model;
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
import eu.inn.sign.datalayer.IDataLayer;
import eu.inn.sign.pdf.document.PdfBinding;
import eu.inn.sign.pdf.document.PdfPageInfo;
import eu.inn.sign.pdf.render.IPdfRenderedListener;
import eu.inn.sign.signature.SignatureField;
import eu.inn.sign.signature.SignatureParameters;
import eu.inn.wssign.InnoSignerFactory;
import eu.inn.wssign.controller.utils.AuditLogger;
import eu.inn.wssign.controller.utils.PdfUtils;

/**
 * Handles requests for the application home page.
 */
@Controller
@RequestMapping("/signManagement")
@SuppressWarnings("unchecked")
public class DocumentSignController {
	@Autowired
	private MessageSource messageSource;

	private static String outputDir = "/home/tomcat/ieess/tempPdfDir";
	static {
		if (Security.getProvider("BC") == null)
			Security.addProvider(new BouncyCastleProvider());
	}

	@Autowired
	private InnoSignerFactory signerFactory;

	@PostConstruct
	public void initializeTempDir() {
		try {

			outputDir = messageSource.getMessage("outputDir", null, null);
			if (!new File(outputDir).exists()) {
				logger.info("Creating temporary directory " + outputDir);
				FileUtils.forceMkdir(new File(outputDir));
			} else
				FileUtils.cleanDirectory(new File(outputDir));

		} catch (Exception ex) {
		}
	}

	@Autowired
	private IDataLayer<UUID> baseDataLayer;

	@RequestMapping(value = "/getBindingInfo", method = RequestMethod.POST)
	public @ResponseBody byte[] getBindingInfo(@RequestParam String uuid) {
		JSONObject ret = new JSONObject();
		try {
			PdfBinding bind = signerFactory.getSigner(uuid).getBindingInfo();// .getLastFile(UUID.fromString(uuid)).getData();
			ret.put("hash", bind.getHash());
			ret.put("count", bind.getCount());
			ret.put("offset", bind.getOffset());
			ret.put("alg", bind.getAlgorithm());
		} catch (Exception e) {
			logger.error("Internal Server Error - " + e.getMessage(), e);
			ret.put("errorMessage", "Cannot get binding. " + e.getMessage());
		}
		return ret.toJSONString().getBytes();

	}

	private static final Logger logger = Logger.getLogger(DocumentSignController.class);

	public DocumentSignController() throws IOException {
	}

	@RequestMapping(value = "/signFEA", method = RequestMethod.POST)
	public @ResponseBody String signFEA(@RequestParam String uuid, @RequestParam String sigName,
			@RequestParam String config, String xmlBioSignature, String base64image,
			@RequestParam(defaultValue = "PAdES-BES") String type, @RequestParam(defaultValue = "0") String docType,
			@RequestParam(defaultValue = "DETACHED") String packaging) {
		JSONObject ret = new JSONObject();
		try {
			logger.debug("Called signFEA ");
			Date from = new Date();
			logger.info("Document to sign uuid: " + uuid);
			if (docType.equals("0"))
				preparePdf(uuid, config);
			else
				throw new IllegalArgumentException("Only pdf are allowed");
			SignatureParameters sp = new SignatureParameters();
			sp.setBioData(xmlBioSignature);
			sp.setSignImageBase64(base64image);
			sp.setName(sigName);
			signerFactory.getSigner(uuid).sign(sp, null);
			ret.put("uuid", uuid);
			ret.put("uuidStep", uuid);
			Date to = new Date();
			long diff = to.getTime() - from.getTime();
			logger.info("Document signed uuid: " + uuid + " time: " + diff + " milliseconds");
		} catch (Exception e) {
			logger.error("Internal Server Error - " + e.getMessage(), e);
			ret.put("errorMessage", "Cannot sign document. " + e.getMessage());
		}
		return ret.toJSONString();
	}

	@RequestMapping(value = "/getImage", method = RequestMethod.GET)
	public @ResponseBody String getPageAsImage(final @RequestParam String uuid, int page, HttpServletResponse res) {
		if (page <= 0)
			throw new ResourceNotFoundException();
		try {
			System.err.println("Generating page " + page);
			final JSONObject pageImage = new JSONObject();
			InnoBaseSign<UUID> s = signerFactory.getSigner(uuid);
			s.getPageImage(page, 2, new IPdfRenderedListener() {
				@Override
				public void onRendered(int page, double scale, byte[] image) {
					pageImage.put("imageb64", Base64.encodeBase64String(image));
				}
			});
			pageImage.put("width", s.getPageInfo(page).getWidth());
			pageImage.put("height", s.getPageInfo(page).getHeight());
			return pageImage.toJSONString();
		} catch (Exception e) {
			logger.error("Internal Server Error - " + e.getMessage());
			e.printStackTrace();
			throw new ResourceNotFoundException();
		}
	}

	@RequestMapping(value = "/undoLastSign", method = RequestMethod.GET)
	public @ResponseBody String undoLastSign(@RequestParam String uuid) {
		JSONObject ret = new JSONObject();
		try {
			logger.debug("Called undoLastSign ");
			logger.info("Document to sign uuid: " + uuid);
			signerFactory.getSigner(uuid).undo(true);
			ret.put("uuid", uuid);
		} catch (Exception e) {
			logger.error("Internal Server Error - " + e.getMessage(), e);
			ret.put("errorMessage", "Cannot undo Last Sign. " + e.getMessage());
		}
		return ret.toJSONString();
	}

	@RequestMapping(value = "/signLocalStep1", method = RequestMethod.POST)
	public @ResponseBody String signLocalStep1(@RequestParam String uuid,
			@RequestParam String docType,
			@RequestParam String type, // DL!!!
			@RequestParam String packaging, @RequestParam String base64Cert, @RequestParam String config,
			@RequestParam String sigName, @RequestParam(defaultValue = "") String sigImageUuid) {
		JSONObject ret = new JSONObject();
		try {
			if (!docType.equals("0"))
				throw new IllegalArgumentException("Only pdf are allowed");
			preparePdf(uuid, config);
			SignatureParameters sp = new SignatureParameters();
			sp.setName(sigName);
			CertificateFactory cf = CertificateFactory.getInstance("X509");
			ByteArrayInputStream bais = new ByteArrayInputStream(Base64.decodeBase64(base64Cert));
			X509Certificate cert = (X509Certificate) cf.generateCertificate(bais);
			try {
				bais.close();
			} catch (Exception ex) {
			}
			byte[] toBeSigned = signerFactory.getSigner(uuid).getToBeSignedData(sp, cert);
			ret.put("signData", Base64.encodeBase64String(toBeSigned));

		} catch (Exception e) {
			ret.put("errorMessage", e.getMessage());
		}
		return ret.toJSONString();
	}

	@RequestMapping(value = "/signLocalStep2", method = RequestMethod.POST)
	public @ResponseBody String signLocalStep2(@RequestParam String uuid, @RequestParam String base64Digest,
			@RequestParam String docType, @RequestParam String sigName) {
		JSONObject ret = new JSONObject();
		try {
			signerFactory.getSigner(uuid).sign(null, Base64.decodeBase64(base64Digest));
			ret.put("uuid", uuid.toString());
		} catch (Exception e) {
			ret.put("errorMessage", e.getMessage());
		}

		return ret.toJSONString();
	}

	@RequestMapping(value = "/upload", method = RequestMethod.POST)
	public @ResponseBody void upload(HttpServletRequest request, HttpServletResponse response) {
		JSONObject ret = new JSONObject();
		try {
			MultipartHttpServletRequest multipartRequest = (MultipartHttpServletRequest) request;
			MultipartFile fileToSignFile = multipartRequest.getFile(multipartRequest.getFileNames().next());
			FileObject toStore = new FileObject(fileToSignFile.getBytes(), fileToSignFile.getOriginalFilename());
			InnoBaseSign<UUID> created = signerFactory.createSigner();
			created.importDocument(toStore);
			UUID generated = created.getUuid();
			signerFactory.putSigner(created);
			if (fileToSignFile.getOriginalFilename().endsWith(".xml")) {
				ret.put("xmlValue", new String(toStore.getData()));
			}
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
	}

	@RequestMapping(value = "/getPdfInfo", method = RequestMethod.POST)
	public @ResponseBody byte[] getPdfInfo(@RequestParam String uuid,
			@RequestParam(defaultValue = "false") boolean skipTextAnalysis) {
		JSONObject ret = new JSONObject();
		try {
			InnoBaseSign<UUID> signer = signerFactory.getSigner(uuid);
			LinkedList<UUID> all = baseDataLayer.getAllFiles(UUID.fromString(uuid));
			ret.put("pagesN", signer.getTotalPages());
			JSONArray signs = new JSONArray();
			ret.put("signatures", signs);
			ret.put("revision", all.size());
			Map<String, SignatureField> signsFound = signer.getSignFields(true, "§dsig", "§");
			for (SignatureField sf : signsFound.values())
				signs.add(PdfUtils.signatureToObject(sf, signer.getPageInfo(sf.getPage())));
			PdfPageInfo p1 = signer.getPageInfo(1);
			ret.put("realWidthPage", p1.getWidth());
			ret.put("realHeightPage", p1.getHeight());
		} catch (Exception e) {
			logger.error("Internal Server Error - " + e.getMessage(), e);
			ret.put("errorMessage", "Cannot get number of pages. " + e.getMessage());
		}
		return ret.toJSONString().getBytes();

	}

	private void preparePdf(String uuid, String configJson) throws Exception {
		InnoBaseSign<UUID> signer = signerFactory.getSigner(uuid);
		JSONParser parser = new JSONParser();
		JSONObject config = (JSONObject) parser.parse(configJson);
		JSONArray array = (JSONArray) config.get("signatureApplied");
		List<SignatureField> toAdd = new ArrayList<SignatureField>();
		for (Object signObj : array) {
			JSONObject signature = (JSONObject) signObj;
			if (!((Boolean) signature.get("isNew")))
				continue;
			SignatureField sf = new SignatureField();
			sf.setName(signature.get("name").toString());
			int page = 1;
			if ((Boolean) signature.get("_isVisible")) {
				page = Integer.parseInt(signature.get("page").toString());
				PdfPageInfo info = signer.getPageInfo(page);
				float realWidth = info.getWidth();
				float realHeight = info.getHeight();
				float pageWidth = Float.parseFloat(signature.get("pageWidth").toString());
				float pageHeight = Float.parseFloat(signature.get("pageHeight").toString());
				float top = Float.parseFloat(signature.get("top").toString()) * realHeight / pageHeight;
				float left = Float.parseFloat(signature.get("left").toString()) * realWidth / pageWidth;
				float width = Float.parseFloat(signature.get("width").toString()) * realWidth / pageWidth;
				float height = Float.parseFloat(signature.get("height").toString()) * realHeight / pageHeight;
				sf.setHeight(height);
				sf.setWidth(width);
				sf.setTop(top);
				sf.setLeft(left);
				sf.setPage(page);
			}
			toAdd.add(sf);
		}
		if (toAdd.isEmpty())
			return;
		signer.createSignatureFields(toAdd);

	}

	@RequestMapping(value = "/prepareDownload", method = RequestMethod.POST)
	public @ResponseBody byte[] prepareDownload(final @RequestParam String uuid, String config,
			HttpServletResponse response) {
		JSONObject ret = new JSONObject();
		try {
			ret.put("uuid", uuid);
		} catch (Exception ex) {
			logger.error("Internal Server Error - " + ex.getMessage(), ex);
			ret.put("errorMessage", "Cannot prepare document. " + ex.getMessage());

		}
		return ret.toJSONString().getBytes();
	}

	@RequestMapping(value = "/download", method = RequestMethod.GET)
	public @ResponseBody byte[] download(final @RequestParam String uuid, HttpServletResponse response,
			HttpServletRequest request) {
		try {
			FileObject last = signerFactory.getSigner(uuid).getFileObject();
			if (last == null)
				throw new Exception("Document " + uuid + " does not exists");
			AuditLogger.LOG(
					Level.INFO,
					String.format("Downloading file with uuid %s from remote address %s:%s with user %s", uuid,
							request.getRemoteAddr(), request.getRemotePort(), request.getRemoteUser()));
			response.setHeader("Content-Disposition", "attachment; filename=\"" + last.getName() + "\"");
			response.setContentLength(last.getData().length);
			response.setContentType("application/octet-stream");
			response.getOutputStream().write(last.getData());
			response.getOutputStream().flush();
			return null;
		} catch (Exception e) {
			logger.error("Internal Server Error - " + e.getMessage());
			throw new ResourceNotFoundException();
		}
	}

	@RequestMapping(value = "/getSigInfo", method = RequestMethod.GET)
	public @ResponseBody String getSigInfo(@RequestParam String uuid, @RequestParam String sigName) {
		JSONObject ret = new JSONObject();
		if (StringUtils.isBlank(uuid) || StringUtils.isBlank(sigName))
			throw new ResourceNotFoundException();
		try {
		} catch (Exception e) {
			logger.error("Internal Server Error - " + e.getMessage());
			ret.put("errorMessage", "Internal Server Error - " + e.getMessage());

		}
		return ret.toJSONString();

	}

	@RequestMapping(value = "/getFileAsB64", method = RequestMethod.GET)
	public @ResponseBody String getFileAsB64(final @RequestParam String uuid, HttpServletResponse res)
			throws IOException {
		try {
			byte[] data = baseDataLayer.getFirstFile(UUID.fromString(uuid)).getData();
			return Base64.encodeBase64String(data);
		} catch (Exception ex) {
			throw new ResourceNotFoundException();
		}
	}

	@RequestMapping(value = "/getFileBytes", method = RequestMethod.GET)
	public @ResponseBody void getFileBytes(final @RequestParam String uuid, HttpServletResponse response)
			throws IOException {
		try {
			FileObject fo = signerFactory.getSigner(uuid).getFileObject();
			byte[] data = fo.getData();
			response.setContentType("application/pdf");
			response.setContentLength(data.length);
			response.setHeader("Content-Disposition", "attachment; filename=\"" + fo.getName() + "\"");
			response.flushBuffer();
			IOUtils.write(data, response.getOutputStream());
		} catch (Exception ex) {
			throw new ResourceNotFoundException();
		}
	}

	@RequestMapping(value = "/edit", method = RequestMethod.GET)
	public String edit(Model model, @RequestParam(defaultValue = "") String uuid,
			@RequestParam(defaultValue = "") String type, @RequestParam(defaultValue = "") String lang) {
		model.addAttribute("uuid", uuid);
		model.addAttribute("type", type);
		model.addAttribute("lang", lang);
		if (type.equals("1"))
			try {
				String xmlDoc = new String(baseDataLayer.getLastFile(UUID.fromString(uuid)).getData());
				model.addAttribute("xmlDoc", xmlDoc.replaceAll("\\r\\n", "").replaceAll("\n", ""));
			} catch (Exception e) {
				// TODO Auto-generated catch block
				e.printStackTrace();
			}
		return "signManagement/edit";
	}

	@RequestMapping(value = "/remoteSign", method = RequestMethod.GET)
	public String remoteSign(Model model, @RequestParam(defaultValue = "") String uuid,
			@RequestParam(defaultValue = "") String type, @RequestParam(defaultValue = "") String lang,
			@RequestParam(defaultValue = "-2") String nextIndex, @RequestParam(defaultValue = "") String callbackURL,
			@RequestParam(defaultValue = "true") boolean enableAddSignature,
			@RequestParam(defaultValue = "true") boolean enableFlatCopy) {
		model.addAttribute("uuid", uuid);
		model.addAttribute("type", type);
		model.addAttribute("lang", lang);
		model.addAttribute("enableAddSignature", enableAddSignature);
		model.addAttribute("nextIndex", Integer.parseInt(nextIndex) + 1);
		try {
			String xmlDoc = new String(baseDataLayer.getLastFile(UUID.fromString(uuid)).getData());
			if (xmlDoc.startsWith("<")) {
				model.addAttribute("documentType", 1);
				model.addAttribute("enableFlatCopy", false);
				model.addAttribute("callbackURL", "remoteSignXmlEnd");
				return "signManagement/remoteSignXml";
			}
		} catch (Exception e) {
			e.printStackTrace();
		}
		model.addAttribute("enableFlatCopy", enableFlatCopy);
		model.addAttribute("callbackURL", callbackURL);
		return "signManagement/remoteSign";
	}

	@RequestMapping(value = "/remoteSignXmlEnd", method = RequestMethod.GET)
	public String remoteSign(Model model, @RequestParam(defaultValue = "") String uuid) throws Exception {
		String xmlDoc = new String(baseDataLayer.getLastFile(UUID.fromString(uuid)).getData());
		model.addAttribute("uuid", uuid);
		model.addAttribute("xml", xmlDoc);
		return "signManagement/remoteSignXmlEnd";
	}

	@RequestMapping(value = "/downloadXml", method = RequestMethod.GET, produces = "application/xml")
	@ResponseBody
	public String downloadXml(Model model, @RequestParam(defaultValue = "") String uuid) throws Exception {
		return new String(baseDataLayer.getLastFile(UUID.fromString(uuid)).getData());
	}

	@RequestMapping(value = "/home", method = RequestMethod.GET)
	public String home() {
		return "signManagement/home";
	}

	@RequestMapping(value = "/home2", method = RequestMethod.GET)
	public String home2() {
		return "signManagement/home2";
	}

	@RequestMapping(value = "/endDocument", method = RequestMethod.GET)
	public String endDocument(@RequestParam(defaultValue = "") String docuuid,
			@RequestParam(defaultValue = "") String callbackURL,
			@RequestParam(defaultValue = "true") boolean enableFlatCopy) throws Exception {
		try {
			logger.info("Document Ended uuid: " + docuuid);
		} catch (Exception e) {
			e.printStackTrace();
		}
		FileObject f = baseDataLayer.getLastFile(UUID.fromString(docuuid));
		if (f == null)
			return "redirect:home";
		if (StringUtils.isNotBlank(callbackURL)) {
			if (enableFlatCopy) {
				try {
					;
					File output = new File(outputDir + "/[FLAT_COPY]" + f.getName());
					if (output.exists()) {
						output.delete();
						Thread.sleep(1000);
					}
					ByteArrayOutputStream outputStream = new ByteArrayOutputStream();
					byte[] data = f.getData();
					PdfReader reader = new PdfReader(data);
					PdfStamper stamp1 = new PdfStamper(reader, outputStream, '\0');
					stamp1.setFormFlattening(true);
					stamp1.close();
					reader.close();
					FileUtils.writeByteArrayToFile(output, outputStream.toByteArray());
				} catch (Exception e) {
					logger.error("Cannot create flat-copy file to output Dir,message:" + e.getMessage());
				}
			}
			return "redirect:" + callbackURL + "?uuid=" + docuuid;
		} else {
			try {
				File output = new File(outputDir + "/" + docuuid + "_" + f.getName());
				if (output.exists()) {
					output.delete();
					Thread.sleep(1000);
				}
				FileUtils.writeByteArrayToFile(output, f.getData());
			} catch (Exception e) {
				logger.error("Cannot copy file to output Dir,message:" + e.getMessage());
			}
			return "redirect:home";
		}
	}

	@RequestMapping(value = "/uploadDocument", method = RequestMethod.GET)
	public String uploadDocument(Model model) {
		return "signManagement/uploadDocument";
	}

	@SuppressWarnings("serial")
	@ResponseStatus(value = HttpStatus.NOT_FOUND)
	public class ResourceNotFoundException extends RuntimeException {

	}

}
