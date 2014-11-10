package eu.inn.wssign;

import java.io.FileInputStream;
import java.io.IOException;
import java.security.GeneralSecurityException;
import java.security.KeyStore;
import java.util.UUID;
import java.util.concurrent.ExecutionException;
import java.util.concurrent.TimeUnit;

import org.apache.commons.lang.StringUtils;

import com.google.common.cache.Cache;
import com.google.common.cache.CacheBuilder;

import eu.inn.sign.InnoBaseSign;
import eu.inn.sign.datalayer.IDataLayer;
import eu.inn.sign.pdf.document.impl.PdfBoxPdfDocumentType;
import eu.inn.sign.pdf.render.IcePdfRenderer;
import eu.inn.sign.pdf.signature.LocalPdfSignatureManager;

public class InnoSignerFactory {

	private IDataLayer<UUID> dataLayer;
	private String storePath;
	private String storeType;
	private String storePwd;
	private String alias;
	private String aliasPwd;

	private KeyStore store = null;

	private synchronized KeyStore getStore() throws GeneralSecurityException, IOException {
		if (store == null) {
			KeyStore ks = KeyStore.getInstance(storeType);
			ks.load(new FileInputStream(storePath), storePwd.toCharArray());
			store = ks;
			if (StringUtils.isBlank(alias))
				alias=ks.aliases().nextElement();
			if (StringUtils.isBlank(aliasPwd))
				aliasPwd=storePwd;
		}
		return store;

	}

	private Cache<UUID, InnoBaseSign<UUID>> cacheSigner = CacheBuilder.newBuilder().concurrencyLevel(4)
			.expireAfterWrite(30, TimeUnit.MINUTES).build();
//			new CacheLoader<UUID, InnoBaseSign<UUID>>() {
//
//				@Override
//				public InnoBaseSign<UUID> load(UUID key) throws Exception {
//
//					PdfBoxPdfDocumentType myDocumentType = new PdfBoxPdfDocumentType();
//					myDocumentType.setPdfRender(new IcePdfRenderer());
//					LocalPdfSignatureManager sigManager = new LocalPdfSignatureManager(getStore(), aliasPwd, alias);
//					return new InnoBaseSign<UUID>(dataLayer, sigManager, myDocumentType);
//
//				}
//
//			});

	public InnoBaseSign<UUID> getSigner(UUID uuid) throws ExecutionException {
		return cacheSigner.getIfPresent(uuid);
	}
	
	public InnoBaseSign<UUID> getSigner(String uuid) throws ExecutionException {
		return getSigner(UUID.fromString(uuid));
	}
	
	public InnoBaseSign<UUID> createSigner() throws Exception {
		
		PdfBoxPdfDocumentType myDocumentType = new PdfBoxPdfDocumentType();
		myDocumentType.setPdfRender(new IcePdfRenderer());
		LocalPdfSignatureManager sigManager = new LocalPdfSignatureManager(getStore(), aliasPwd, alias);
		InnoBaseSign<UUID> ret = new InnoBaseSign<UUID>(dataLayer, sigManager, myDocumentType);
		
		return ret;
	}	
	public void putSigner(InnoBaseSign<UUID> toAdd) throws ExecutionException {
		cacheSigner.put(toAdd.getUuid(), toAdd);
	}

	public void setDataLayer(IDataLayer<UUID> dataLayer) {
		this.dataLayer = dataLayer;
	}

	public void setStorePath(String storePath) {
		this.storePath = storePath;
	}

	public void setStoreType(String storeType) {
		this.storeType = storeType;
	}

	public void setStorePwd(String storePwd) {
		this.storePwd = storePwd;
	}

	public void setAlias(String alias) {
		this.alias = alias;
	}

	public void setAliasPwd(String aliasPwd) {
		this.aliasPwd = aliasPwd;
	}
}
