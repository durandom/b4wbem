/*
 *
 * JavaScript-functions for PaulA-Frontend
 *
 */

/*
 * Special functions for all forms
 */

var propArr = new Array();
var mandatories = new Array();

function uploadBackup()
{
	return false;
}

function downloadBackup()
{
	return false;
}

/*
	Sobald eine Zugriffsrecht für ein bestimmtes Formular geändert wird
	muss es im versteckten String ebenfalls geändert werden.
*/
function changeRange( rangeDestName, i )
{
	var form	= document.forms[0];
	var rangeSrcName;
	
	if( i == 0 )	rangeSrcName = rangeDestName + "Start";
	else		rangeSrcName = rangeDestName + "End";
	
	var destTag	= eval( "form."+ rangeDestName );
	var srcTag	= eval( "form."+ rangeSrcName );
	
	var newvalue	= srcTag.value;
	var oldvalues	= destTag.value;	// this is sth: like "300::303"
	
	var values	= oldvalues.split("::");
	var oldvalue	= values[ i ];
	
	values[ i ]	= newvalue;
		
	if( values[0]*1 > values[1]*1 )	// uhh, compare values not strings!!!
	{
		alert(	"Die angegebenen Intervallgrenzen "+ values[0] +"/"+ values[1] +" stimmen nicht:\n"+
			"Der erste Wert muss kleiner sein als der zweite!" );
		srcTag.value = oldvalue;
		
		return;
	}

	if( values[0].length != values[1].length )
	{
		alert(	"Bitte achten Sie darauf, dass die Länge der Zahlen\n"+
			"der beiden Intervallgrenzen übereinstimmt!\n"+
			"Fügen Sie ggf. führende Nullen an." );
	}
	destTag.value	= values.join("::");

	// evtl. leere Liste abfangen!?
	
	return;
} // changeRange()




/*
	Sobald eine Zugriffsrecht für ein bestimmtes Formular geändert wird
	muss es im versteckten String ebenfalls geändert werden.
*/
function changePermission( permissionName )
{
	var form	= document.forms[0];
	var permTag	= eval( "form."+permissionName );
	var permVal	= "";
	
	// get default/selected value from changed tag
	for( k=0; k < permTag.length; k++ )
	{
		if( permTag.options[k].selected)
		{
			permVal = permTag.options[k].value;
		}
	}


	var permStrPart	= permissionName+"_"+permVal;	// z.B.: USERLOGIN_w
	
	var hiddenTag	= form.Permissions;		// <HARDCODED/> !!! Kann irgendwann mal anders heißen!!!
	var hiddenStr	= hiddenTag.value;

	var permArr	= hiddenStr.split("::");
	var len		= permArr.length;
	
//	alert( permissionName+"\n"+permVal );
	
	for( var i=0; i < len; i++ )
	{
		var reg = eval( "/^"+permissionName+"/" );
		
		if( reg.test( permArr[i] ) )
		{
//			alert("Gefunden:"+permissionName+"_"+permVal+" war "+permArr[i] );
			
			permArr[i] = permStrPart;
		}
	}
	
	hiddenTag.value = permArr.join("::");

	// evtl. leere Liste abfangen!?
	
	return;
} // changePermission()



function clearEditField()
{
	document.forms[0].editfield.value = '  ';
}


// submit - allgemein

function generalSubmit()
{
	var form = document.forms[0];
	var rc = true;
	
	if( form.editfield )
	{
		clearEditField();
	}

	if( form.Password )
	{
		rc = pwValidate('Password') && rc;
	}
	else if( form.PrivatePopPassword )
	{
		rc = pwValidate('PrivatePopPassword') && rc;
	}

	return rc;
}

// submit - allgemein


function evalSubmit()
{	
	var f = document.forms[0];


	if( f.editfield )
	{
		if( f.editfield.value != "  " )
		{
			if( addItemToEdList( f.editlist.name ) ) // works only with one editlist per form!
			{
				f.editfield.value = "";
				f.editfield.focus();
			}
			return false;
		}
	}


	//currNode.modified = false;
	f.ModifiedProperties.value = '';
	var ooi = '';
	for(i in propArr)
	{
		var cField = eval('f.'+i);	// in case of radio-buttons it's undef
		
		// alert( "Checking "+i+"\nValue: "+cField.value+"\nMandatory: "+mandatories[ cField.name ] );
		
		if( !cField )
		{
			alert( "Couldn't find hiddenfield for "+ i );
			continue;		// strange, I dare say impossible!
		}

		var cFieldModified = false;
		
		if( mandatories[ i ] == 1 )
		{
			//alert( "Found a mandatory: "+cField.name );
			cFieldModified = true;
		}
		else
		{
			if (cField.type == 'select-one')
			{
				var selValue = '';
				for (k=0;k<cField.length;k++)
				{
					if (cField.options[k].selected)
					{
						selValue = cField.options[k].value;
						if (selValue != propArr[i]) cFieldModified = true;
					}
		  		}
		  		ooi += "\n"+cField.name+' als '+cField.type+' mit '+selValue;
			}
			else if (cField.type == 'checkbox')
			{
				var cFieldModified = false;
				var selValue = '0';
				if (cField.checked) selValue='1';
				if (cField.checked != cField.defaultChecked) cFieldModified = true;
				ooi += "\n"+cField.name+' als '+cField.type+' mit '+selValue;
			}
			else if (cField[0] && cField[0].type == 'radio')
			{
				ooi += "\n"+cField[0].name+' als '+cField[0].type;
				for (k = 0; k < cField.length; k++)
				{
					// if (cField[k].checked != cField[k].defaultChecked)
					if( cField[k].checked != propArr[i] )
						cFieldModified = true;
				}
			}
			else
			{
				ooi += "\n"+cField.name+' als '+cField.type+' mit '+cField.value;
				if (cField.value != propArr[i]) cFieldModified = true;
			}
		} // mandatories
		
		if (cFieldModified)
		{
			var pre = "::";
			if (f.ModifiedProperties.value == '') pre="";
				f.ModifiedProperties.value += pre + i;
		}
	} // for propArr
	
	// alert(f.ModifiedProperties.value);
	// alert("Untersuchte Felder:\n"+ooi);
	// return false;
	return true;
}



function evalListSubmit(currList)
{
	var form = document.forms[0];
	
		if (form.editfield.value != "  ") {
			if (addItemToEdList(currList)) {
				form.editfield.value = "";
				form.editfield.focus();
			}
			return false;
		}
	return evalSubmit();
}




function showHelpE(e) {

	var helpdiv = e.target.src;
	var divCount = document.layers.length;
	var xC = e.x;
	var yC = e.y;
	var re = /?/;
	if (re.test(helpdiv))
	{
		helpdiv = helpdiv.split("?")[1];
		var cDiv = eval('document.'+helpdiv);
		cDiv.x = xC + 35;
		cDiv.y = yC - 20;
		// Hide all other HelpDiv's
		for (i=0;i<divCount;i++)
		{
			if (cDiv.name == document.layers[i].name) continue;
			var re = /Div$/;
			if (re.test(document.layers[i].name))
			{
				document.layers[i].visibility = 'hide';
			}
		}
		if (cDiv.visibility == 'hide')
			cDiv.visibility = 'show';
		else
			cDiv.visibility = 'hide';
	}
}

// password

function pwValidate(pwFieldName) {
	var pw1 = eval("document.forms[0]."+pwFieldName+".value");
	var pw2 = eval("document.forms[0]."+pwFieldName+"Sec.value");
	if(pw1 != pw2) {
		alert("Die Passwoerter sind nicht identisch. Bitte nochmal eingeben.");
		return false;
	}
	return true;
}

// password

// boolselect

function toggleCheckboxValue(currBool) {
	var currBoolNam = "document.forms[0]." + currBool;
	var currBoolObj = eval(currBoolNam);
		
	if (currBoolObj) {
		if( currBoolObj.value == '0' || currBoolObj.value == '' )
			currBoolObj.value = '1';
		else 
			currBoolObj.value = '0';
	}
}

// exchangelist

function addAllToExList(currList) {
	var form	 = document.forms[0];
	var compList = form.completelist.options;
	var seleList = form.selectlist.options;
	var maxC	 = compList.length;
	var maxS	 = seleList.length;
	for (var i = 0; i < maxC; i++) {
		var currVal = compList[i].value;
		var currTxt = compList[i].text;
		var itsNotInS = true;
		for (var k = 0; k < maxS; k++) {
			if(currVal == seleList[k].value) itsNotInS = false; 
		}
		if (itsNotInS) {
			seleList[maxS] = new Option(currTxt, currVal);
			maxS++;
		}
	}
	trackOptInExList(currList);
}

function addItemToExList(currList) {
	var form = document.forms[0];
	var compList = form.completelist.options;
	var seleList = form.selectlist.options;
	var maxC	 = compList.length;
	var maxS	 = seleList.length;
	for (var i = 0; i < maxC; i++) {
		if(compList[i].selected) {
			var currVal = compList[i].value;
			var currTxt = compList[i].text;
			var itsNotInM = true;
			for (var k = 0; k < maxS; k++) {
				if(currVal == seleList[k].value) itsNotInM = false; 
			}
			if (itsNotInM) {
				seleList[maxS] = new Option(currTxt, currVal);
				maxS++;
			}
		}
	}
	trackOptInExList(currList);
}

function removeItemFromExList(currList) {
	var seleList = document.forms[0].selectlist.options;
	for (var i = seleList.length - 1; i >= 0; i--) {
		if(seleList[i].selected) seleList[i] = null;
	}
	trackOptInExList(currList);
}

function removeAllFromExList(currList) {
	var seleList = document.forms[0].selectlist.options;
	var max = seleList.length;
	for(var i=0; i < max; i++) seleList[0] = null;
	trackOptInExList(currList);
}

function trackOptInExList(currList)
{
	var form = document.forms[0];
	var seleList = form.selectlist.options;
	//if (!form.hiddenlist_name) return;
	//var hiddenlist = form.hiddenlist_name.value;
	//hiddenlist = eval("form."+hiddenlist);
	if (!currList) return;
	
	hiddenlist = eval("form."+currList);
	
	var max = seleList.length;
	var optArr = new Array();
	
	for (var i = 0; i < max; i++) optArr[i] = seleList[i].value;
	
	hiddenlist.value = optArr.join("::");
	if (max == 0) hiddenlist.value = "";
	
	return;
}

// exchangelist

// editlist

function addItemToEdList(currList) {
	var form	= document.forms[0];
	var editField	= form.editfield;
	var re		= /^\s*$/;
	
	if (re.test(editField.value))
	{
		return;
	}
	
	if (form.name == 'USERMAIL') {
		var re = /.*@[^\.]+\.[^\.]+$/;
		if (!re.exec(editField.value)) {
			alert("Benutze eine gueltige Email-Adresse.");   // Check only if realy needed
			editField.focus();
			return false;
		}
	}
	var editList = form.editlist
	var l		= editList.options.length;
	editList.options[l] = new Option(editField.value, editField.value);
	editField.value = "";
	editField.focus();
	trackOptInEdList(currList);
	return true;
}

function editItemInEdList(currList) {
	addItemToEdList(currList);
	var form = document.forms[0];
	var editList = form.editlist.options;
	for (var i = 0; i < editList.length; i++) {
		if (editList[i].selected) {
			form.editfield.value = editList[i].value;
			editList[i--] = null;
			form.editfield.focus();
			trackOptInEdList(currList);
		break;
		}
	}
	for (var i = 0; i < editList.length; i++) {
		editList[i].selected = false;
	}
}

function removeItemFromEdList(currList) {
	var editList = document.forms[0].editlist.options;
	for (var i = editList.length - 1; i >= 0; i--) {
		if (editList[i].selected) editList[i] = null;
	}
	trackOptInEdList(currList);
}

function trackOptInEdList(currList)
{
	var form	= document.forms[0];
	var editList	= form.editlist.options;
	
	if( currList )
	{
		var max		= editList.length;
		var optArr	= new Array();
		hiddenlist	= eval("form."+currList);
		
		for (var i = 0; i < max; i++)
			optArr[i] = editList[i].text;

		hiddenlist.value = optArr.join("::");
		
		if (max == 0)
			hiddenlist.value = "";
	}
}

// editlist

// editIPList

function addItemToIPList(currList) {
	var form	  = document.forms[0];
	var editField = form.ip1.value+"."+form.ip2.value+".";
	editField	+= form.ip3.value+"."+form.ip4.value;
	if (editField != '...') {
		var re = /^\d{1,3}\.\d{1,3}\.\d{1,3}\.\d{1,3}$/;
		if (!re.test(editField))  {alert('IP-Wert ungueltig!');return;}
		if (form.ip1.value > 255) {alert('IP-Wert ungueltig!');return;}
		if (form.ip2.value > 255) {alert('IP-Wert ungueltig!');return;}
		if (form.ip3.value > 255) {alert('IP-Wert ungueltig!');return;}
		if (form.ip4.value > 255) {alert('IP-Wert ungueltig!');return;}
		var editList  = form.editlist
		var l		 = editList.options.length;
		editList.options[l] = new Option(editField, editField);
		form.ip1.value = form.ip2.value = form.ip3.value = form.ip4.value = "";
		form.ip1.focus();
		trackOptInIPList(currList);
	}
}

function editItemInIPList(currList) {
	addItemToIPList(currList);
	var form = document.forms[0];
	var editList = form.editlist.options;
	for (var i = 0; i < editList.length; i++) {
		if (editList[i].selected) {
			var ipArr = editList[i].value;
			ipArr = ipArr.split(".");
			form.ip1.value = ipArr[0];
			form.ip2.value = ipArr[1];
			form.ip3.value = ipArr[2];
			form.ip4.value = ipArr[3];
			editList[i--] = null;
			form.ip1.focus();
			trackOptInIPList(currList);
			break;
		}
	}
	for (var i = 0; i < editList.length; i++) {
		editList[i].selected = false;
	}
}

function removeItemFromIPList(currList) {
	var editList = document.forms[0].editlist.options;
	for (var i = editList.length - 1; i >= 0; i--) {
		if (editList[i].selected) editList[i] = null;
	}
	trackOptInIPList(currList);
}

function trackOptInIPList(currList) {
	var form	   = document.forms[0];
	var editList   = form.editlist.options;
	if (currList) {
	  hiddenlist = eval("form."+currList);
	  var max = editList.length;
	  var optArr = new Array();
	  for (var i = 0; i < max; i++)  optArr[i] = editList[i].text;
	  hiddenlist.value = optArr.join("::");
	  if (max == 0) hiddenlist.value = "";
	}
}

function validateIP(ipName) {
	var cVal = eval('document.forms[0].' + ipName + '.value');  
	var re = /^\d{1,3}$/;
	if (!re.test(cVal) || cVal > 255) {
		if (cVal != '') alert('IP-Wert '+cVal+' ungueltig');
	}
}
// editIPList

// editIPIPList  (different from editIPList!!!)

function addItemToIPIPList(currList) {
	var form	  = document.forms[0];
	var ipsField  = form.ips1.value+"."+form.ips2.value+".";
	ipsField	 += form.ips3.value+"."+form.ips4.value;
	var ipeField  = form.ipe1.value+"."+form.ipe2.value+".";
	ipeField	 += form.ipe3.value+"."+form.ipe4.value;
	if (ipsField != '...' ) {
		var re = /^\d{1,3}\.\d{1,3}\.\d{1,3}\.\d{1,3}$/;
		if (!re.test(ipsField))  {alert('IP-Wert '+ipsField+' ungueltig!');return;}
		if (form.ips1.value > 255) {alert('IP-Wert ungueltig!');return;}
		if (form.ips2.value > 255) {alert('IP-Wert ungueltig!');return;}
		if (form.ips3.value > 255) {alert('IP-Wert ungueltig!');return;}
		if (form.ips4.value > 255) {alert('IP-Wert ungueltig!');return;}
		if (ipeField != '...') {
		  if (!re.test(ipeField))  {alert('IP-Wert '+ipeField+' ungueltig!');return;}
		  if (form.ipe1.value > 255) {alert('IP-Wert ungueltig!');return;}
		  if (form.ipe2.value > 255) {alert('IP-Wert ungueltig!');return;}
		  if (form.ipe3.value > 255) {alert('IP-Wert ungueltig!');return;}
		  if (form.ipe4.value > 255) {alert('IP-Wert ungueltig!');return;}
		  editField = ipsField + '-' + ipeField;
		} else {
		  editField = ipsField;
		}
		var editList  = form.editlist
		var l		 = editList.options.length;
		editList.options[l] = new Option(editField, editField);
		form.ips1.value = form.ips2.value = form.ips3.value = form.ips4.value = "";
		form.ipe1.value = form.ipe2.value = form.ipe3.value = form.ipe4.value = "";
		form.ips1.focus();
		trackOptInIPIPList(currList);
	}
}

function editItemInIPIPList(currList) {
	addItemToIPIPList(currList);
	var form = document.forms[0];
	var editList = form.editlist.options;
	for (var i = 0; i < editList.length; i++) {
		if (editList[i].selected) {
			var edArr  = editList[i].value;
			edArr	  = edArr.split("-");
			var ipsArr = edArr[0];
			ipsArr	 = ipsArr.split(".");
			form.ips1.value = ipsArr[0];
			form.ips2.value = ipsArr[1];
			form.ips3.value = ipsArr[2];
			form.ips4.value = ipsArr[3];
			if (edArr[1]) {
			  var ipeArr  = edArr[1];
			  ipeArr	  = ipeArr.split(".");
			  form.ipe1.value = ipeArr[0];
			  form.ipe2.value = ipeArr[1];
			  form.ipe3.value = ipeArr[2];
			  form.ipe4.value = ipeArr[3];
			}
			editList[i--] = null;
			form.ips1.focus();
			trackOptInIPIPList(currList);
			break;
		}
	}
	for (var i = 0; i < editList.length; i++) {
		editList[i].selected = false;
	}
}

function removeItemFromIPIPList(currList) {
	var editList = document.forms[0].editlist.options;
	for (var i = editList.length - 1; i >= 0; i--) {
		if (editList[i].selected) editList[i] = null;
	}
	trackOptInIPIPList(currList);
}

function trackOptInIPIPList(currList) {
	var form	   = document.forms[0];
	var editList   = form.editlist.options;
	if (currList) {
	  hiddenlist = eval("form."+currList);
	  var max = editList.length;
	  var optArr = new Array();
	  for (var i = 0; i < max; i++)  optArr[i] = editList[i].text;
	  hiddenlist.value = optArr.join("::");
	  if (max == 0) hiddenlist.value = "";
	}
}

// editIPIPList

// editMACIPList
function addItemToMACList(currList) {
	var form	  = document.forms[0];
	var editMAC   = form.mac1.value+":"+form.mac2.value+":";
	editMAC	  += form.mac3.value+":"+form.mac4.value+":";
	editMAC	  += form.mac5.value+":"+form.mac6.value;
	editIP		= form.ip1.value+"."+form.ip2.value+".";
	editIP	   += form.ip3.value+"."+form.ip4.value;
	var re = /^\d{1,3}\.\d{1,3}\.\d{1,3}\.\d{1,3}$/;
	if (!re.test(editIP)) return;
	if (form.ip1.value > 255) {alert('IP-Wertebereich falsch!');return;}
	if (form.ip2.value > 255) {alert('IP-Wertebereich falsch!');return;}
	if (form.ip3.value > 255) {alert('IP-Wertebereich falsch!');return;}
	if (form.ip4.value > 255) {alert('IP-Wertebereich falsch!');return;}
	editField = editMAC + "-" + editIP;
	var editList  = form.editlist
	var l		 = editList.options.length;
	editList.options[l] = new Option(editField, editField);
	form.mac1.value = form.mac2.value = form.mac3.value = "";
	form.mac4.value = form.mac5.value = form.mac6.value = "";
	form.ip1.value = form.ip2.value = form.ip3.value = form.ip4.value = "";
	form.ip1.focus();
	trackOptInMACList(currList);
}

function editItemInMACList(currList) {
	addItemToMACList(currList);
	var form = document.forms[0];
	var editList = form.editlist.options;
	for (var i = 0; i < editList.length; i++) {
		if (editList[i].selected) {
			var edArr  = editList[i].value;
			edArr	  = edArr.split("-");
			var macArr = edArr[0];
			macArr	 = macArr.split(":");
			form.mac1.value = macArr[0];
			form.mac2.value = macArr[1];
			form.mac3.value = macArr[2];
			form.mac4.value = macArr[3];
			form.mac5.value = macArr[4];
			form.mac6.value = macArr[5];
			var ipArr  = edArr[1];
			ipArr	  = ipArr.split(".");
			form.ip1.value = ipArr[0];
			form.ip2.value = ipArr[1];
			form.ip3.value = ipArr[2];
			form.ip4.value = ipArr[3];
			editList[i--] = null;
			form.ip1.focus();
			trackOptInMACList(currList);
			break;
		}
	}
	for (var i = 0; i < editList.length; i++) {
		editList[i].selected = false;
	}
}

function removeItemFromMACList(currList) {
	var editList = document.forms[0].editlist.options;
	for (var i = editList.length - 1; i >= 0; i--) {
		if (editList[i].selected) editList[i] = null;
	}
	trackOptInMACList(currList);
}

function trackOptInMACList(currList) {
	var form	   = document.forms[0];
	var editList   = form.editlist.options;
	if (currList) {
	  hiddenlist = eval("form."+currList);
	  var max = editList.length;
	  var optArr = new Array();
	  for (var i = 0; i < max; i++)  optArr[i] = editList[i].text;
	  hiddenlist.value = optArr.join("::");
	  if (max == 0) hiddenlist.value = "";
	}
}
//editMACIPList


// inputIP
function updateIP(ipName)
{
	var cIpName	= ipName;
	var form	= 'document.forms[0].';
	var hiddenIpName = cIpName.substring( 0, cIpName.length-1 );
	var cIpNo	= cIpName.substring( cIpName.length-1, cIpName.length );
	
	if( eval( form + hiddenIpName ) )
	{
		var hiddenIpField	= eval(form + hiddenIpName);
		var oldIPs		= hiddenIpField.value.split(".");
		var cIpField		= eval(form + cIpName);
		var ip1Val		= eval(form + hiddenIpName + '1.value');
		var ip2Val		= eval(form + hiddenIpName + '2.value');
		var ip3Val		= eval(form + hiddenIpName + '3.value');
		var ip4Val		= eval(form + hiddenIpName + '4.value');
		var newIpName		= ip1Val + '.' + ip2Val + '.' + ip3Val + '.' + ip4Val;
		
		var re = /^\d{1,3}$/;
		
		if( !re.test( cIpField.value ) || cIpField.value > 255 )
		{
			if (cIpField.value != '')
			{
				alert('IP-Wert ungueltig');
				
				cIpField.value = oldIPs[ cIpNo - 1 ] ? oldIPs[ cIpNo - 1 ] : "";
			}
			else
			{
				if (newIpName == '...') hiddenIpField.value = '';
			}
		}
		else
		{
			re = /^\d{1,3}\.\d{1,3}\.\d{1,3}\.\d{1,3}$/;
			if( re.test(newIpName) && ip1Val<256 && ip2Val<256 && ip3Val<256 && ip4Val<256 )
			{
					hiddenIpField.value = newIpName;
			}
		}
	}
}


