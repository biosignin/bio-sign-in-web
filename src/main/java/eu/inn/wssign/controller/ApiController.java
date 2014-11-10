package eu.inn.wssign.controller;

import java.io.ByteArrayInputStream;
import java.io.IOException;
import java.security.cert.CertificateFactory;
import java.security.cert.X509Certificate;
import java.util.ArrayList;
import java.util.Collection;
import java.util.List;
import java.util.UUID;

import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;

import org.apache.commons.codec.binary.Base64;
import org.apache.commons.io.IOUtils;
import org.apache.log4j.Level;
import org.apache.log4j.Logger;
import org.json.simple.JSONArray;
import org.json.simple.JSONObject;
import org.json.simple.parser.JSONParser;
//import org.slf4j.Logger;
//import org.slf4j.LoggerFactory;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.http.HttpStatus;
import org.springframework.stereotype.Controller;
import org.springframework.validation.BindingResult;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RequestMethod;
import org.springframework.web.bind.annotation.RequestParam;
import org.springframework.web.bind.annotation.ResponseBody;
import org.springframework.web.bind.annotation.ResponseStatus;
import org.springframework.web.multipart.MultipartFile;
import org.springframework.web.multipart.MultipartHttpServletRequest;

import eu.inn.sign.InnoBaseSign;
import eu.inn.sign.datalayer.FileObject;
import eu.inn.sign.pdf.document.PdfBinding;
import eu.inn.sign.pdf.document.PdfPageInfo;
import eu.inn.sign.signature.ParsedSignatureField;
import eu.inn.sign.signature.SignatureField;
import eu.inn.sign.signature.SignatureParameters;
import eu.inn.wssign.InnoSignerFactory;
import eu.inn.wssign.controller.utils.AuditLogger;

/**
 * Handles requests for the application home page.
 */
@Controller
@RequestMapping("/api")
@SuppressWarnings("unchecked")
public class ApiController {

	// @Autowired
	// private IDataLayer<UUID> dataLayer;

	@Autowired
	private InnoSignerFactory signerFactory;

	@RequestMapping(value = "/getBindingInfo")
	public @ResponseBody byte[] getBindingInfo(@RequestParam String uuid) {

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
		return ret.toJSONString().getBytes();

	}

	// @Resource
	// WebServiceTemplate localwsNoAuth;

	private static final Logger logger = Logger.getLogger(ApiController.class);

	public ApiController() throws IOException {

	}

	@RequestMapping(value = "/signFEA", method = RequestMethod.POST)
	public @ResponseBody String signFEA(@RequestParam String uuid, @RequestParam String sigName,
			@RequestParam String xmlBioSignature, @RequestParam String base64image
//			,
//			@RequestParam(defaultValue = "PAdES-BES") String type, @RequestParam(defaultValue = "0") String docType,
//			@RequestParam(defaultValue = "DETACHED") String packaging
			) {
		JSONObject ret = new JSONObject();

		try {
			SignatureParameters sp = new SignatureParameters();
			sp.setBioData(xmlBioSignature);
			sp.setSignImageBase64(base64image);
			sp.setName(sigName);
			signerFactory.getSigner(uuid).sign(sp, null);
//			
//			Date from = new Date();
//			FileObject last = dataLayer.getLastFile(UUID.fromString(uuid));
//			Image image = null;
//			if (StringUtils.isNotBlank(base64image)) {
//				Base64Encoder encoder = new Base64Encoder();
//				ByteArrayOutputStream baos = new ByteArrayOutputStream();
//				encoder.decode(base64image, baos);
//				baos.flush();
//				byte[] bytesImage = baos.toByteArray();
//				baos.close();
//				image = new Image();
//				image.setImgb(bytesImage);
//				image.setAbsoluteX(50);
//				image.setAbsoluteY(50);
//			}
//
//			byte[] data = last.getData();
//
//			String feaUsername = "";// messageSource.getMessage("fea.username",
//									// null, null);
//
//			String feaPassword = "";// messageSource.getMessage("fea.pin", null,
//									// null);
//
//			SignRequest sr = new SignRequest().withPIN(feaPassword).withSignatureType(type).withSignDocument(data)
//					.withUserName(feaUsername).withSignName(sigName).withImage(image).withBiosignature(xmlBioSignature)
//					.withSignPackaging(packaging).withUseP12(true);
//
//			SignResponse res = (SignResponse) localwsNoAuth.marshalSendAndReceive(sr);
//
//			if (StringUtils.isNotBlank(res.getErrors()))
//				throw new Exception(res.getErrors());
//
//			String fileName = last.getName();
//
//			// originalFileName = originalFileName.replace(stepId, "");
//			if (docType.equals("2"))
//				fileName += ".p7m";
//			FileObject toAdd = new FileObject(res.getSignedDocument(), fileName);
//			UUID newUUID = dataLayer.addFile(UUID.fromString(uuid), toAdd);

			ret.put("uuid", uuid.toString());
//			ret.put("uuidStep", newUUID.toString());
//			Date to = new Date();
//			long diff = to.getTime() - from.getTime();
//			logger.info("Document signed uuid: " + uuid + " time: " + diff + " milliseconds");

		} catch (Exception e) {
			logger.error("Internal Server Error - " + e.getMessage(), e);
			ret.put("errorMessage", "Cannot sign document. " + e.getMessage());
		}
		return ret.toJSONString();
	}

	@RequestMapping(value = "/undoLastSign", method = RequestMethod.POST)
	public @ResponseBody String undoLastSign(@RequestParam String uuid) {
		JSONObject ret = new JSONObject();
		try {
			logger.debug("Called undoLastSign ");
			logger.info("Document to sign uuid: " + uuid);
			signerFactory.getSigner(uuid).undo();
			ret.put("uuid", uuid);
		} catch (Exception e) {
			logger.error("Internal Server Error - " + e.getMessage(), e);
			ret.put("errorMessage", "Cannot undo Last Sign. " + e.getMessage());
		}
		return ret.toJSONString();
	}

	@RequestMapping(value = "/signLocalStep1", method = RequestMethod.POST)
	public @ResponseBody String signLocalStep1(@RequestParam String uuid, @RequestParam String base64Cert,
			@RequestParam String sigName, 
//			@RequestParam(defaultValue = "PAdES-BES") String type,
//			@RequestParam(defaultValue = "DETACHED") String packaging,
			@RequestParam(defaultValue = "") String xmlBioSignature,
			@RequestParam(defaultValue = "") String base64image
			) {
		JSONObject ret = new JSONObject();
		try {
			SignatureParameters sp = new SignatureParameters();
			sp.setBioData(xmlBioSignature);
			sp.setSignImageBase64(base64image);
			sp.setName(sigName);
			CertificateFactory cf = CertificateFactory.getInstance("X509");
			ByteArrayInputStream bais = new ByteArrayInputStream(Base64.decodeBase64(base64Cert));
			X509Certificate cert = (X509Certificate) cf
					.generateCertificate(bais);
			try {
				bais.close();
			}catch (Exception ex) {}
			byte[] toBeSigned = signerFactory.getSigner(uuid).getToBeSignedData(sp, cert);
			ret.put("signData", Base64.encodeBase64String(toBeSigned));			
		} catch (Exception e) {
			ret.put("errorMessage", e.getMessage());
		}
		return ret.toJSONString();
	}

	@RequestMapping(value = "/signLocalStep2", method = RequestMethod.POST)
	public @ResponseBody String signLocalStep2(@RequestParam String uuid,
//			@RequestParam(defaultValue = "0") String docType, 
//			@RequestParam String sigName,
			@RequestParam String base64Digest) {
		JSONObject ret = new JSONObject();
		try {
			signerFactory.getSigner(uuid).sign(null, Base64.decodeBase64(base64Digest));
			// String last = cacheDocs.getIfPresent(UUID.fromString(uuid)).getLast().toString();
//			FileObject last = dataLayer.getLastFile(UUID.fromString(uuid));
//			Authentication auth = SecurityContextHolder.getContext().getAuthentication();
//			ApplicationAuth appAuth = new ApplicationAuth();
//			appAuth.withApplicationName("IESS").withApplicationPassword("iess_innovery")
//					.withOragnization("organization").withGroupName("user");
//			if (auth != null) {
//				UserDetailBean user = (UserDetailBean) auth.getPrincipal();
//				appAuth.withOragnization(user.getOrganization()).withGroupName(user.getGroup())
//						.withApplicationName("IESS").withApplicationPassword("iess_innovery");
//			}
//			SignV2Request srv2 = new SignV2Request().withSignedDigest(Base64.decode(base64Digest))
//					.withIsLocalSign(true).withUuid(uuid).withSignName(sigName).withAuth(appAuth);
//
//			SignV2Response resv2 = (SignV2Response) localwsNoAuth.marshalSendAndReceive(srv2);
//
//			String fileName = last.getName();
//
//			// originalFileName = originalFileName.replace(stepId, "");
//			if (docType.equals("2"))
//				fileName += ".p7m";
//			FileObject toAdd = new FileObject(resv2.getSignedDocument(), fileName);
//			UUID newUUID = dataLayer.addFile(UUID.fromString(uuid), toAdd);

			ret.put("uuid", uuid.toString());
//			if (docType.equals("1"))
//				ret.put("xmlDocument", new String(resv2.getSignedDocument()));
//
//			ret.put("uuidStep", newUUID.toString());
		} catch (Exception e) {
			ret.put("errorMessage", e.getMessage());
		}

		return ret.toJSONString();
	}

	@RequestMapping(value = "/upload", method = RequestMethod.POST)
	// @PreAuthorize("hasRole('"+FunctionEnum.PERMISSION_AUTOENROLL_BIO_SIGNATURE+"')")
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
			logger.info("Upload Document uuid: " + generated.toString());
			ret.put("uuid", generated.toString());

		} catch (Exception e) {
			logger.error("Internal Server Error - " + e.getMessage(), e);
			ret.put("errorMessage", "Cannot upload document. " + e.getMessage());
		}

		try {
			response.getOutputStream().print(ret.toJSONString());
		} catch (IOException e) {
			// TODO Auto-generated catch block
			e.printStackTrace();
		}
		// turn ret.toJSONString();

	}

	// private static JSONObject signatureToObject(PdfReader reader, String fieldName, boolean signed) {
	// JSONObject ret = new JSONObject();
	//
	// ret.put("name", fieldName);
	// ret.put("signed", signed);
	// float[] positions = reader.getAcroFields().getFieldPositions(fieldName);
	// com.lowagie.text.Rectangle pageSize = reader.getPageSize((int) positions[0]);
	// ret.put("page", (int) positions[0]);
	// ret.put("left", positions[1]);
	// ret.put("top", pageSize.getHeight() - positions[4]);
	// ret.put("width", positions[3] - positions[1]);
	// ret.put("height", positions[4] - positions[2]);
	//
	// return ret;
	// }

	private static JSONObject signatureToObject(SignatureField s) {
		JSONObject ret = new JSONObject();
		if (s instanceof ParsedSignatureField) {
			ret.put("text", ((ParsedSignatureField) s).getText());
			ret.put("created", ((ParsedSignatureField) s).isCreated());
		} else {
			ret.put("name", s.getName());
			ret.put("signed", s.isSigned());
			ret.put("width", s.getWidth());
			ret.put("height", s.getHeight());
		}
		ret.put("page", s.getPage());
		ret.put("left", s.getLeft());
		ret.put("top", s.getTop());

		return ret;
	}

	@RequestMapping(value = "/getTotalPages")
	public @ResponseBody byte[] getPdfInfo(@RequestParam String uuid) {
		JSONObject ret = new JSONObject();
		try {
			ret.put("pages", signerFactory.getSigner(uuid).getTotalPages());
		} catch (Exception e) {
			logger.error("Internal Server Error - " + e.getMessage(), e);
			ret.put("errorMessage", "Cannot get signatures. " + e.getMessage());
		}
		return ret.toJSONString().getBytes();
	}


	@RequestMapping(value = "/getPageInfo")
	public @ResponseBody byte[] getPdfInfo(@RequestParam String uuid, @RequestParam int page) {
		JSONObject ret = new JSONObject();
		try {
			PdfPageInfo pInfo = signerFactory.getSigner(uuid).getPageInfo(page);
			ret.put("realHeightPage", pInfo.getHeight());
			ret.put("realWidthPage", pInfo.getWidth());
		} catch (Exception e) {
			logger.error("Internal Server Error - " + e.getMessage(), e);
			ret.put("errorMessage", "Cannot get signatures. " + e.getMessage());
		}
		return ret.toJSONString().getBytes();
	}

	@RequestMapping(value = "/getSignatures", consumes = "*/*; charset=utf-8", method = RequestMethod.POST)
	public @ResponseBody byte[] getSignatures(@RequestParam String uuid,
			@RequestParam(defaultValue = "true") boolean skipTextAnalysis,
			@RequestParam(defaultValue = "§dsig") String prefix, @RequestParam(required = false) String suffix) {

		JSONObject ret = new JSONObject();
		try {
			Collection<SignatureField> sigs = signerFactory.getSigner(uuid).getSignFields(!skipTextAnalysis, prefix, suffix).values();
			JSONArray signs = new JSONArray();
			ret.put("signatures", signs);
			for (SignatureField s : sigs)
				signs.add(signatureToObject(s));

		} catch (Exception e) {
			logger.error("Internal Server Error - " + e.getMessage(), e);
			ret.put("errorMessage", "Cannot get signatures. " + e.getMessage());
		}
		return ret.toJSONString().getBytes();

	}

	@RequestMapping(value = "/addSignatureFields", method = RequestMethod.POST)
	public @ResponseBody byte[] addSignatureFields(final @RequestParam String uuid, String signatures, @RequestParam(defaultValue="true") boolean throwsOnError) {
		JSONObject ret = new JSONObject();
		try {
			List<SignatureField> fieldToAdd = new ArrayList<SignatureField>();

			JSONParser parser = new JSONParser();
			JSONObject config = (JSONObject) parser.parse(signatures);
			JSONArray array = (JSONArray) config.get("signatures");
			for (Object signObj : array) {
				JSONObject signature = (JSONObject) signObj;
				float height = Float.parseFloat(signature.get("height").toString());
				float width = Float.parseFloat(signature.get("width").toString());
				SignatureField s = new SignatureField();
				s.setName(signature.get("name").toString());
				if (height > 0 && width > 0) {
					s.setPage(Integer.parseInt(signature.get("page").toString()));
					s.setLeft(Float.parseFloat(signature.get("left").toString()));
					s.setTop(Float.parseFloat(signature.get("top").toString()));
					s.setHeight(height);
					s.setWidth(width);
				}
				fieldToAdd.add(s);
			}
			signerFactory.getSigner(uuid).createSignatureFields(fieldToAdd, throwsOnError);
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
			FileObject f = signerFactory.getSigner(uuid).getFileObject();
			if (f == null)
				throw new Exception("Document " + uuid + " does not exists");
			AuditLogger.LOG(
					Level.INFO,
					String.format("Downloading file with uuid %s from remote address %s:%s with user %s", uuid,
							request.getRemoteAddr(), request.getRemotePort(), request.getRemoteUser()));
			// byte[] data = FileUtils.readFileToByteArray(f);
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

	}

	@RequestMapping(value = "/exists", method = RequestMethod.GET)
	public @ResponseBody byte[] exists(final @RequestParam String uuid) throws IOException {

		JSONObject ret = new JSONObject();
		try {

			UUID masterUuid = UUID.fromString(uuid);
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
		return ret.toJSONString().getBytes();
	}

	@RequestMapping(value = "/getFileBytes", method = RequestMethod.GET)
	public @ResponseBody void getFileBytes(final @RequestParam String uuid, HttpServletResponse response)
			throws IOException {

		try {
			byte[] data = signerFactory.getSigner(uuid).getFileObject().getData();
			response.setContentType("application/pdf");
			response.setContentLength(data.length);
			response.setHeader("Content-Disposition", "attachment; filename=\"" + uuid + ".pdf\"");
			response.flushBuffer();
			IOUtils.write(data, response.getOutputStream());
		} catch (Exception ex) {
			throw new ResourceNotFoundException();
		}
	}

	@SuppressWarnings("serial")
	@ResponseStatus(value = HttpStatus.NOT_FOUND)
	public class ResourceNotFoundException extends RuntimeException {

	}	

}
