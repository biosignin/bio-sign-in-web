package eu.inn.wssign.controller.utils;

import org.json.simple.JSONObject;

import eu.inn.sign.pdf.document.PdfPageInfo;
import eu.inn.sign.signature.ParsedSignatureField;
import eu.inn.sign.signature.SignatureField;

@SuppressWarnings("unchecked")
public class PdfUtils {

	public static JSONObject signatureToObject(SignatureField field, PdfPageInfo info) {
		JSONObject ret = new JSONObject();

		ret.put("name", field.getName());
		ret.put("signed", field.isSigned());
		ret.put("page", field.getPage());
		ret.put("left", field.getLeft() * 4 / 3);
		ret.put("top", field.getTop() * 4 / 3);
		ret.put("width", field.getWidth() * 4 / 3);
		ret.put("height", field.getHeight() * 4 / 3);
		ret.put("pageWidth", info.getWidth() * 4 / 3);
		ret.put("pageHeight", info.getHeight() * 4 / 3);
		if (field instanceof ParsedSignatureField) {
			ParsedSignatureField pField = (ParsedSignatureField) field;
			ret.put("isNew", !pField.isCreated());

			ret.put("mandatory", pField.isMandatory());
			ret.put("displayName", pField.getName());
			ret.put("description", "desc N/A");
			ret.put("dsig", pField.getText());

		} else
			ret.put("isNew", false);

		return ret;
	}

}
