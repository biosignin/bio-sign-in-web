package eu.inn.sign.signature;

import java.beans.PropertyEditorSupport;

import org.codehaus.jackson.map.ObjectMapper;

import eu.inn.sign.web.util.JsonSerializer;

public class SignatureParametersEditor extends PropertyEditorSupport {
	ObjectMapper mapper = new ObjectMapper();
	SignatureParameters value;

	@Override
	public Object getValue() {
		return value;
	}

	@Override
	public void setAsText(String text) throws IllegalArgumentException {
		try {
			value = JsonSerializer.readSignatureParameters(text);
		} catch (Throwable e) {
			throw new IllegalArgumentException(e);
		}
	}
}
