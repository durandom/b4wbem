<?xml version="1.0" encoding="iso-8859-1"?>
<!DOCTYPE config [
<!ENTITY prefix "">
<!ENTITY newline '<xsl:text>
</xsl:text>'>
<!ENTITY questionmark '
&newline;
<td align="right"><xsl:text>&#160;</xsl:text>
<xsl:if test="../../docs/help/@name = ./@name">
	<img src="&prefix;/WebFrontend/images/blind.gif" width="15" border="0"/>
	<span style="position:relative">
		<xsl:attribute name="name"><xsl:value-of select="@name"/>Q</xsl:attribute>
		<img border="0" align="absmiddle">
			<xsl:attribute name="src"><xsl:text>&prefix;/WebFrontend/images/question1.png?</xsl:text><xsl:value-of select="@name"/>Div</xsl:attribute>
		</img>
	</span>&newline;
<script language="Javascript">setTimeout("document.<xsl:value-of select="@name"/>Q.document.captureEvents(Event.MOUSEDOWN)",500);
setTimeout("document.<xsl:value-of select="@name"/>Q.document.onmousedown=showHelpE",500);
</script>&newline;&newline;
</xsl:if>
</td>
'>

<!ENTITY blindImage '<img src="&prefix;/WebFrontend/images/blind.gif" height="17" width="1"/>'>
<!ENTITY printproperty '<i><xsl:value-of select="."/><xsl:text>&#160;</xsl:text></i>'>
<!ENTITY insertName '<xsl:attribute name="name">
  <xsl:value-of select="@name"/>
</xsl:attribute>'>

]>

<!--
	Mit Hilfe dieser XSL-Datei koennen xml-Daten in HTML-Daten umgewandelt
	wewrden.
-->
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform" version="1.0">
<xsl:output media-type="text/html" encoding="iso-8859-1"/>

<!-- Setzen von Konstanten fuer die Darstellung -->

<xsl:variable name="barcolor">#E6F0FF</xsl:variable> 
<xsl:variable name="fieldcolor">#EEEEEE</xsl:variable> 
<xsl:variable name="bgcolor">#FFFFFF</xsl:variable>

<!-- Definition der Templates -->

<xsl:template match="/">
<html>
    <style>
        <![CDATA[
        body {
            background-color: #FFFFFF;
            margin: 0;
        }
        .title {
            text-decoration: none;
            font-family: Arial, Helvetica; 
            font-size: 14pt; 
            color: #00378a; 
            font-weight: bold;
        }
        .small {
            font-family: Arial, Helvetica; 
            font-size: 8pt;
        }
        .content {
            font-family: Arial, Helvetica; 
            font-size: 10pt;
        }
	.help
	{
		position:absolute;
		left:600;
		top:15;
		width:300;
		height:200;
		visibility:hidden;
		border-color:#000000;
		border-style:inset;
		border-width:medium;
		background-color:#f5f5dc
	}
        ]]>
    </style>

        <head>
               <!--<meta http-equiv="Content-Type" content="text/html; charset=iso-8859-1" />-->
               <script language="JavaScript" src="&prefix;/WebFrontend/jscript/forms.js"></script>&newline;
		<title>PaulA</title>&newline;
	</head>&newline;
	<body leftmargin="0" topmargin="0" marginwidth="0" marginheight="0">&newline;
        <xsl:apply-templates select="paula/form/docs/help"/>
	<form method="post" action="/paul-setcim">
		<xsl:attribute name="name">
                    <xsl:value-of select="paula/form/@name"/>
                </xsl:attribute>&newline;

	        <table border="1" cellspacing="0" cellpadding="10">
		    <xsl:attribute name="bgcolor"><xsl:value-of select="$fieldcolor"/></xsl:attribute>&newline;

		    <xsl:apply-templates select="paula/form"/>

	        </table>&newline;

	</form>&newline;
	</body>&newline;
	</html>&newline;
</xsl:template>

<!-- ___node___________________________________________________________ -->
<xsl:template match="node">
&newline;
</xsl:template>
<!-- ___node___________________________________________________________ -->




<!-- ___form___________________________________________________________ -->
<xsl:template match="form">

	<!-- Alle Knoten unterhalb von "form" bearbeiten! -->
	<xsl:apply-templates select="./*"/>

&newline;
</xsl:template>
<!-- ___form___________________________________________________________ -->



<!-- ___docs___________________________________________________________ -->
<xsl:template match="docs">
	<tr>
	<xsl:attribute name="bgcolor"><xsl:value-of select="$barcolor"/></xsl:attribute>&newline;
		<td colspan="2" align="LEFT">&newline;
		  <div class="title">
                    <nobr>
                      <xsl:value-of select="./title" />
                    </nobr>
                  </div>&newline;
                </td>&newline;
                <td align="RIGHT">
                  <div class="content">
                    <font>
                      <input type="button" name="help" value="Hilfe">
                        <xsl:attribute name="cellspacing">0</xsl:attribute>
                      </input>
                    </font>
                  </div>
                </td>&newline;
	</tr>&newline;
&newline;
</xsl:template>
<!-- ___docs___________________________________________________________ -->


<!-- ___components_____________________________________________________ -->
<xsl:template match="components">

        <xsl:for-each select="./*">
		<xsl:apply-templates select="."/>
	</xsl:for-each>

&newline;
</xsl:template> 
<!-- ___components_____________________________________________________ -->



<!-- ___help_____________________________________________________ -->
<xsl:template match="help">
	<div class="help">
		<xsl:attribute name="name"><xsl:value-of select="@name"/>Div</xsl:attribute>
		<xsl:text><xsl:value-of select="."/></xsl:text>
	</div>
&newline;
</xsl:template> 


<!-- ___help_____________________________________________________ -->



<!-- ___actions________________________________________________________ -->
<xsl:template match="actions">
	<tr>
		<xsl:attribute name="bgcolor"><xsl:value-of select="$barcolor"/></xsl:attribute>&newline;

		<xsl:if test="count(./submit)&gt;0">
			<td>
				<div class="content">
					<xsl:apply-templates select="submit"/>
				</div>
			</td>&newline;
		</xsl:if>
                <td align="right">
			<xsl:attribute name="colspan">
				<xsl:if test="count(./submit)=0">3</xsl:if>
				<xsl:if test="count(./submit)&gt;0">2</xsl:if>
			</xsl:attribute>
				

			<div class="content">
				<xsl:for-each select="(./action | ./reset | ./hiddenfield)">
					<xsl:apply-templates select="."/>
				</xsl:for-each>
				<xsl:if test="not(./action | ./reset)">
					<xsl:text>&#160;</xsl:text>
				</xsl:if>
			</div>&newline;
                </td>&newline;
	</tr>&newline;
&newline;
</xsl:template> 
<!-- ___actions________________________________________________________ -->



<!-- ___submit_________________________________________________________ -->
<xsl:template match="submit">
	<xsl:text>Keine Schreibberechtigung!</xsl:text>
&newline;
</xsl:template>
<!-- ___submit_________________________________________________________ -->



<!-- ___reset_________________________________________________________ -->
<xsl:template match="reset">
	<xsl:text>&#160;</xsl:text>
&newline;
</xsl:template>
<!-- ___submit_________________________________________________________ -->



<!-- ___action_________________________________________________________ -->
<xsl:template match="action">
	<xsl:text>&#160;</xsl:text>
&newline;
</xsl:template>                                                                
<!-- ___action_________________________________________________________ -->
                                                  



<!--
	Hier beginnen die Definitionen der "Visuellen"-Elemente
-->


<!-- ___externalLink___________________________________________________ -->
<xsl:template match="externalLink">
  	&newline;
	<tr>
		<td colspan="2" align="center">&newline;
			<span class="content">
			<a>
				<xsl:attribute name="href"><xsl:value-of select="@src"/></xsl:attribute>
				<xsl:value-of select="."/>
			</a>
			</span>&newline;
		</td>&newline;
		&questionmark;
	</tr>
&newline;
</xsl:template>                                                                
<!-- ___externalLink___________________________________________________ -->
                                                  



<!-- ___inputrange_____________________________________________________ -->
<xsl:template match="inputrange">
	<tr>
		<td colspan="2">
			<div class="content">
				<xsl:value-of select="@label"/>
			</div>
		</td>&newline;
		&questionmark;
	</tr>

	<xsl:for-each select="./*">	<!-- rangestart/-end -->
	<tr>
		<td><xsl:text>&#160;</xsl:text></td>
		<td class="content">
			<!-- set the appropriate label (text) -->
			<xsl:if test="name()='rangestart'"><xsl:value-of select="../@startLabel"/></xsl:if>
			<xsl:if test="name()='rangeend'"  ><xsl:value-of select="../@endLabel"  /></xsl:if>
		</td>
		<td class="content">
			<i><xsl:value-of select="."/></i>
		</td>&newline;
	</tr>&newline;
	</xsl:for-each>
&newline;
</xsl:template>                                                                
<!-- ___inputrange_____________________________________________________ -->
                                                  




<!-- ___filerequest____________________________________________________ -->
<xsl:template match="filerequest">
	<tr>
		<td>
                	<div class="content">
			    <xsl:value-of select="@label"/>
                	</div>
		</td>
		<td>
                	<div class="content"><i>nicht auswählbar</i></div>
		</td>
		&questionmark;
	</tr>
&newline;
</xsl:template>                                                                
<!-- ___filerequest____________________________________________________ -->
                                                  

<!-- __hiddenfield_____________________________________________________ -->
<xsl:template match="hiddenfield">
 
        <input type="hidden">&insertName;
		<xsl:attribute name="value">
        		<xsl:value-of select="@value"/>
		</xsl:attribute>
        </input>

&newline;
</xsl:template>
<!-- ___hiddenfield_____________________________________________________ -->                                             


<!-- ___text___________________________________________________________ -->
<xsl:template match="text">
	<tr>
		<td colspan="2">
			<span class="content">
				&printproperty;
			</span>
		</td>
		&questionmark;
	</tr>
&newline;
</xsl:template>                                                                
<!-- ___text___________________________________________________________ -->


<!-- ___inputfield_____________________________________________________ -->
<xsl:template match="inputfield">
	<tr>
		<td>
                	<div class="content">
			    <xsl:value-of select="@label"/>
                	</div>
		</td>
		<td>
                	<span class="content">
				&printproperty;
                	</span>
		</td>
		&questionmark;
	</tr>
&newline;
</xsl:template>                                                                
<!-- ___inputfield_____________________________________________________ -->
                                                  


<!-- ___inputarea______________________________________________________ -->
<xsl:template match="inputarea">
	<tr>
	<td valign="top">
		<div class="content">
			<xsl:value-of select="@label"/>
		</div>
	</td>
	<td>
                <span class="content">
			&printproperty;
        	</span>
	</td>
	&questionmark;
	</tr>
&newline;
</xsl:template>                                                                
<!-- ___inputarea_____________________________________________________ -->
                                                  


<!-- ___password_______________________________________________________ -->
<xsl:template match="password">
	<tr>
	<td>
                <div class="content">
			<xsl:value-of select="@label" />
                </div>
	</td>
	<td>
                <span class="content">
			<i><xsl:text>********</xsl:text></i>
		</span>
	</td>
	&questionmark;
	</tr>
&newline;
</xsl:template>                                                                
<!-- ___password_______________________________________________________ -->
                                                  



<!-- ___inputtime______________________________________________________ -->
<xsl:template match="inputtime">
	<tr>
	<td>
		<div class="content">
			<xsl:value-of select="@label"/>
		</div>
	</td>
	<td>
		<div class="content">
			&printproperty;
		</div>
	</td>
	&questionmark;
	</tr>
&newline;
</xsl:template>                                                                
<!-- ___inputtime______________________________________________________ -->
                                                  


<!-- ___inputvalue_____________________________________________________ -->
<xsl:template match="inputvalue">
	<tr>
	<td>
		<div class="content">
			<xsl:value-of select="@label"/>
		</div>
	</td>
	<td>
		<div class="content">
			&printproperty;
		</div>
	</td>
	&questionmark;
	</tr>
&newline;
</xsl:template>                                                                
<!-- ___inputvalue_____________________________________________________ -->
                                                  


<!-- ___singleselect___________________________________________________ -->
<xsl:template match="singleselect">
	<tr>
	<td valign="top">
                <span class="content">
			<xsl:value-of select="@label"/>
			&blindImage;
		</span>
	</td>
	<td>
		<div class="content">
			<xsl:if test="not(count(./default) = 0)">
				<xsl:apply-templates select="./default"/>
			</xsl:if>
			<xsl:if test="count(./default)=0">
				<xsl:text>Kein Vorgabewert ausgew&#228;hlt aus:</xsl:text><br/>
				<xsl:apply-templates select="./choice"/>
			</xsl:if>
		</div>
	</td>
	&questionmark;
	</tr>
&newline;
</xsl:template>
<!-- ___singleselect___________________________________________________ -->




<!-- ___permissionlist_________________________________________________ -->
<xsl:template match="permissionlist">
	<xsl:for-each select="./*">
		<xsl:apply-templates select="."/>	<!-- permissionselect -->
	</xsl:for-each>
&newline;
</xsl:template>                                                              
<!-- ___permissionlist_________________________________________________ -->



<!-- ___permissionselect_______________________________________________ -->
<xsl:template match="permissionselect">
	<tr>
	<td valign="top">
                <span class="content">
			<xsl:value-of select="@label"/>
                </span>
                &blindImage;
	</td>
	<td>
		<div class="content">
			<xsl:apply-templates select="./default"/>
		</div>
	</td>
	&questionmark;
	</tr>
&newline;
</xsl:template>
<!-- ___permissionselect_______________________________________________ -->


<!-- ___default________________________________________________________ -->
<xsl:template match="default">

	&printproperty;
	<br/>

&newline;
</xsl:template>
<!-- ___default________________________________________________________ -->



<!-- ___choice_________________________________________________________ -->
<xsl:template match="choice">

	<xsl:text>- </xsl:text>
	&printproperty;
	<br/>

&newline;
</xsl:template>
<!-- ___choice_________________________________________________________ -->



<!-- ___boolselect_____________________________________________________ -->
<xsl:template match="boolselect">
	<tr>
	<td>
                <div class="content">
			<xsl:value-of select="@label"/>
		</div>
	</td>
	<td>
                <div class="content">
		<i>
			<!-- Wenn eine Beschriftung angegeben wird, sollte sie nicht umgebrochen werden! -->
			<xsl:if test="not(string(.)='')">
				<nobr><xsl:value-of select="."/></nobr>
			</xsl:if>
			
			<xsl:choose>

				<xsl:when test="@value='1'">
					<xsl:text> aktiviert</xsl:text>
				</xsl:when>
				<xsl:when test="@value='0'">
					<xsl:text> deaktiviert</xsl:text>
				</xsl:when>
				<xsl:otherwise>
					<xsl:text> undefiniert</xsl:text>
				</xsl:otherwise>
				
			</xsl:choose>
		</i>
		</div>
	</td>
	&questionmark;
	</tr>
&newline;
</xsl:template>                                                                
<!-- ___boolselect_____________________________________________________ -->



<!-- ___inputIP________________________________________________________ -->
<xsl:template match="inputIP">
	<tr>
	<td>
		<div class="content">
			<xsl:value-of select="@label"/>
		</div>
	</td>
	<td>
		<div class="content">
			&printproperty;
		</div>
	</td>
	&questionmark;
	</tr>
&newline;
</xsl:template>                                                                
<!-- ___inputIP________________________________________________________ -->
                                                  


<!-- ___template:lists_________________________________________________ -->
<xsl:template name="lists">

	<xsl:for-each select="./list">
	<tr>&newline;
	        <xsl:if test="not(string(@label)='')">
		<td valign="top">
			<div class="content">
				<xsl:value-of select="@label"/>
				&blindImage;
			</div>
		</td>
		</xsl:if>

		<td>
			<xsl:if test="string(@label)=''">
				<xsl:attribute name="colspan">2</xsl:attribute>
			</xsl:if>
			<i>
				<span class="content">
					<xsl:apply-templates select="./member"/>
					<xsl:if test="count(./member)=0">
						<xsl:text>&#160;</xsl:text>
					</xsl:if>
				</span>
			</i>
	        </td>
		<td>	
			<!-- Fragezeichen mit anderer Knotenposition! -->
			<xsl:if test="../../../docs/help/@name = @name">
				<img src="&prefix;/WebFrontend/images/blind.gif" width="15" border="0"/>
				<span style="position:relative">
					<xsl:attribute name="name"><xsl:value-of select="./@name"/>Q</xsl:attribute>
					<img border="0">
						<xsl:attribute name="src">
						<xsl:text>&prefix;/WebFrontend/images/question1.png?</xsl:text>
						<xsl:value-of select="./@name"/>Div</xsl:attribute>
					</img>
				</span>
				<script language="Javascript">
					<xsl:text>setTimeout("document.<xsl:value-of select="./@name"/>Q.document.captureEvents(Event.MOUSEDOWN)",500);</xsl:text>&newline;
					<xsl:text>setTimeout("document.<xsl:value-of select="./@name"/>Q.document.onmousedown=showHelpE",500);</xsl:text>
				</script>&newline;
			</xsl:if>
			<xsl:if test="not(../../../docs/help/@name = @name)">
				<xsl:text>&#160;</xsl:text>
			</xsl:if>
			
			<!-- -->
	        </td>
	</tr>&newline;	
	</xsl:for-each>
</xsl:template>
<!-- ___template:lists_________________________________________________ -->




<!-- ___editlist_______________________________________________________ -->
<xsl:template match="editlist">

	<xsl:call-template name="lists"/>&newline;
	
</xsl:template>
<!-- ___editlist_______________________________________________________ -->




<!-- ___list___________________________________________________________ -->
<xsl:template match="list">

	<xsl:if test="count(./member)=0"><xsl:text>&#160;</xsl:text></xsl:if>
	&newline;
	<xsl:apply-templates select="./member"/>
		
&newline;
</xsl:template>
<!-- ___list___________________________________________________________ -->



<!-- ___member_________________________________________________________ -->
<xsl:template match="member">
	
	<xsl:text>- </xsl:text><xsl:value-of select="."/>
	<br/>
&newline;
</xsl:template>
<!-- ___member_________________________________________________________ -->




<!-- ___exchangelist___________________________________________________ -->
<xsl:template match="exchangelist">

	<xsl:for-each select="./list">
	<tr>
	        <xsl:if test="not(string(@label)='')">
			<td valign="top">
				<div class="content">
					<xsl:value-of select="@label"/>
					&blindImage;
				</div>
			</td>
		</xsl:if>

		<span class="content">
		<td>
			<xsl:if test="string(@label)=''">
				<xsl:attribute name="colspan">2</xsl:attribute>
			</xsl:if>
			<i>&newline;
				<xsl:apply-templates select="./member"/>
				<xsl:if test="count(./member)=0">
					<xsl:text>&#160;</xsl:text>
				</xsl:if>
			</i>
	        </td>
		</span>
		
		<td>
			<xsl:if test="not(position()=last())">
				<xsl:text>&#160;</xsl:text>
			</xsl:if>

			<xsl:if test="position()=last()">

	<!-- Fragezeichen mit anderer Knotenposition und anderer name-Referenz fuer die Hilfe -->
	<xsl:if test="../../../docs/help/@name = ../@name">
		<img src="&prefix;/WebFrontend/images/blind.gif" width="15" border="0"/>
		<span style="position:relative">
			<xsl:attribute name="name"><xsl:value-of select="../@name"/>Q</xsl:attribute>
			<img border="0">
				<xsl:attribute name="src">
				<xsl:text>&prefix;/WebFrontend/images/question1.png?</xsl:text>
				<xsl:value-of select="../@name"/>Div</xsl:attribute>
			</img>
		</span>
		<script language="Javascript">
			<xsl:text>setTimeout("document.<xsl:value-of select="../@name"/>Q.document.captureEvents(Event.MOUSEDOWN)",500);</xsl:text>&newline;
			<xsl:text>setTimeout("document.<xsl:value-of select="../@name"/>Q.document.onmousedown=showHelpE",500);</xsl:text>
		</script>&newline;
	</xsl:if>
	<!-- -->

			</xsl:if>
	        </td>
	</tr>&newline;
	</xsl:for-each>
&newline;
</xsl:template>
<!-- ___exchangelist___________________________________________________ -->



<!-- ___exchangebuttons________________________________________________ -->
<xsl:template name="exchangebuttons">

&newline;
</xsl:template>
<!-- ___exchangebuttons________________________________________________ -->



<!-- ___editIPIPlist___________________________________________________ -->
<xsl:template match="editIPIPlist">

	<tr>&newline;
		<td><div class="content">IP-Startadresse</div></td>
		<td><div class="content">IP-Endadresse (optional)</div></td>
		<td>&#160;</td>&newline;
	</tr>&newline;
	
	<tr>&newline;
		<span class="content">&newline;
		<td>
			<i>
			
			<xsl:if test="count(./member)=0"><xsl:text>&#160;</xsl:text></xsl:if>
			
			<xsl:for-each select="./list/member">
				<xsl:value-of select="substring-before( string(.), '-' )"/>
				<br/>
			</xsl:for-each>
			
			</i>
	        </td>&newline;
		<td>
			<i>
			
			<xsl:if test="count(./member)=0"><xsl:text>&#160;</xsl:text></xsl:if>
			
			<xsl:for-each select="./list/member">
				<xsl:value-of select="substring-after( string(.), '-' )"/>
				<br/>
			</xsl:for-each>
			
			</i>
	        </td>&newline;

		</span>&newline;
		
		<td align="right"><xsl:text>&#160;</xsl:text>
			<!-- Fragezeichen im Listenknoten -->
			<xsl:if test="../../docs/help/@name = list/@name">
			  <img src="&prefix;/WebFrontend/images/blind.gif" width="15" border="0"/>
			  <span style="position:relative">
			    <xsl:attribute name="name">
			      <xsl:value-of select="list/@name"/>
			      <xsl:text>Q</xsl:text>
			    </xsl:attribute>
			    <img border="0">
			      <xsl:attribute name="src">
        			<xsl:text>&prefix;/WebFrontend/images/question1.png?</xsl:text>
        			<xsl:value-of select="list/@name"/>
        			<xsl:text>Div</xsl:text>
			      </xsl:attribute>
			    </img>
			  </span>
			  <script language="Javascript">
			    <xsl:text>setTimeout("document.</xsl:text>
			    <xsl:value-of select="list/@name" />
			    <xsl:text>Q.document.captureEvents(Event.MOUSEDOWN)",500);</xsl:text>
			    <xsl:text>setTimeout("document.</xsl:text>
			    <xsl:value-of select="list/@name" />
			    <xsl:text>Q.document.onmousedown=showHelpE",500);</xsl:text>
			  </script>
			</xsl:if>
		</td>
		
	</tr>&newline;

&newline;
</xsl:template>
<!-- ___editIPIPlist___________________________________________________ -->


<!-- ___editIPlist_____________________________________________________ -->
<xsl:template match="editIPlist">

	<xsl:call-template name="lists"/>

&newline;
</xsl:template>
<!-- ___editIPlist_____________________________________________________ -->




<!-- ___editMACIPlist__________________________________________________ -->
<xsl:template match="editMACIPlist">
	
	<xsl:call-template name="lists"/>

&newline;
</xsl:template>
<!-- ___editMACIPlist__________________________________________________ -->




</xsl:stylesheet>
