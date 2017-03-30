package eu.inn.sign.signature;

import java.util.List;

public class SignatureStructure {
	private List<DocumentStructure> documents;
	
	public List<DocumentStructure> getDocuments() {
		return documents;
	}
	public void setDocuments(List<DocumentStructure> documents) {
		this.documents = documents;
	}
	
	public class FieldStructure
	{
		private float width;
		private float height;
		private int page;
		private float left;
		private float top;
		private float pageWidth;
		private float pageHeight;
		
		public float getWidth() {
			return width;
		}
		public void setWidth(float width) {
			this.width = width;
		}
		public float getHeight() {
			return height;
		}
		public void setHeight(float height) {
			this.height = height;
		}
		public int getPage() {
			return page;
		}
		public void setPage(int page) {
			this.page = page;
		}
		public float getLeft() {
			return left;
		}
		public void setLeft(float left) {
			this.left = left;
		}
		public float getTop() {
			return top;
		}
		public void setTop(float top) {
			this.top = top;
		}
		public float getPageWidth() {
			return pageWidth;
		}
		public void setPageWidth(float pageWidth) {
			this.pageWidth = pageWidth;
		}
		public float getPageHeight() {
			return pageHeight;
		}
		public void setPageHeight(float pageHeight) {
			this.pageHeight = pageHeight;
		}
	}
	public class DocumentStructure
	{
		private int idDocumentType;
		private List<FieldStructure> fields;
		public int getIdDocumentType() {
			return idDocumentType;
		}
		public void setIdDocumentType(int idDocumentType) {
			this.idDocumentType = idDocumentType;
		}
		public List<FieldStructure> getFields() {
			return fields;
		}
		public void setFields(List<FieldStructure> fields) {
			this.fields = fields;
		}
	}
	
}
