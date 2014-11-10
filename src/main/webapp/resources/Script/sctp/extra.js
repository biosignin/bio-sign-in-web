function loginSmartCard()
{
	 $("#pin-error").text("");
	 var lib = "bit4xpki".split(".")[0] + "|" + "c:\\windows\\system32\\" +"|";
	 //var lib = "|" + "" +"|"+$("#p11Param").val();
	 plugin().setP11Lib(getSlot(),lib);
    var rv = plugin().cardLogIn(getSlot(),$("#pinSmartCard").val());
        if(rv== 0){
          return true;
        }
        if(error()) {
            return false;
        }
        $("#pin-error").text(rv);
   
}

	var getSignCert = function(slot) {

	   var KU_NON_REPUDIATION = 0x0040;
	   var KU_DIGITAL_SIGNATURE = 0x0080;
	   var certs = plugin().getKeysList(slot, KU_NON_REPUDIATION).split(";");
	   console.log("CERT, Looking for NON_REPUDIATION certificates returned " + (certs.length-1) + " certificates");
	   if (certs.length === 2)
	    return certs[0].split("|")[0];
	   
	   certs = plugin().getKeysList(slot, KU_DIGITAL_SIGNATURE).split(";");
	   console.log("CERT, Looking for DIGITAL_SIGNATURE certificates returned " + (certs.length-1) + " certificates");
	   if (certs.length === 2)
	    return certs[0].split("|")[0];
	   
	   return null;
	  };
	  
  