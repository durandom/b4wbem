<?xml version="1.0"?>
<!DOCTYPE config [
<!ENTITY prefix "">
]>
<!--
	Umwandlung der Menue-Struktur in eine HTML/Java-Script-Seite
-->
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform" version="1.0">
<xsl:output media-type="text/html" encoding="iso-8859-1"/>

<!--
<table cellpadding=0 cellspacing=1 border=0><tr bgcolor=#
00378a><td align=left valign=top width=130>&nbsp;<font class=NAV>

</font></td></tr></table>
--> 

<!-- Definition der Templates -->

<xsl:template match="/">
	<html>
		<head>
                    <style type="text/css">
                        .NAV {        
                          text-decoration: none;
                          font-family: Arial, Helvetica;
                          font-size: 10pt;
                          color: #ffffff
                        }
                        .SNAV {
                          text-decoration: none;
                          font-family: Arial, Helvetica;
                          font-size: 10pt;
                          color: #00378a
                        }   
                        .SNAVSEL {
                          text-decoration: none;
                          font-family: Arial, Helvetica;
                          font-size: 10pt;
                          color: red
                        }   
                    </style>
                    <script language="JavaScript" SRC="&prefix;/WebFrontend/jscript/Tree_ie.js"/>
		    <title>Menu</title>
		</head>
                <xsl:text>&#160;</xsl:text>
		<body LEFTMARGIN="0" TOPMARGIN="0" MARGINWIDTH="0" MARGINHEIGHT="0" BGCOLOR="#FFFFFF">
                        &#160;
			<script LANGUAGE="JavaScript">

                          <xsl:text>paulTree=new Tree("first",'[</xsl:text>

	                <!-- oberstes Knotenelement ist das Firmenlogo -->

	                <xsl:text>\'</xsl:text>
                            <img src="&prefix;/WebFrontend/images/id-pro.gif" width="130" height="50" alt="ID-PRO" border="0" />
	                <xsl:text>\',</xsl:text>

	                <!-- Knotenelemente aus paula.xml -->
	
			<xsl:for-each select="node/*">
				<xsl:apply-templates select="."/>

				<!--<xsl:if test="not(position()=last())">-->
					<xsl:text>,</xsl:text>
				<!--</xsl:if>-->
			</xsl:for-each>

	                <!-- letztes Knotenelement ist der Slogan -->

	                <xsl:text>\'</xsl:text>
                            <img src="&prefix;/WebFrontend/images/blind.gif" width="20" height="20" alt="blind" border="0" />
	                <xsl:text>\',</xsl:text>

	                <xsl:text>\'</xsl:text>
                            <img src="&prefix;/WebFrontend/images/id_slogan_H30.jpg" width="130" height="30" alt="slogan" border="0" />
	                <xsl:text>\'</xsl:text>

                        <xsl:text>]');</xsl:text>

                        <xsl:text>if (document.location.search == "?submenu=USER") expandNamedNode('NODE-USER');</xsl:text>
	                <xsl:text>if (document.location.search == "?submenu=GROUPRIGHTS") expandNamedNode('NODE-GROUPRIGHTS');</xsl:text>
	                <xsl:text>if (document.location.search == "?submenu=SEND") expandNamedNode('NODE-SEND');</xsl:text>
	                <xsl:text>if (document.location.search == "?submenu=RECEIVE") expandNamedNode('NODE-RECEIVE');</xsl:text>

			</script>
		</body>
	</html>
</xsl:template>

<!-- ___node___________________________________________________________ -->
<xsl:template match="node">

	<!-- wenn es keine Unterknoten gibt, dann die Referenz erzeugen -->

	<xsl:choose>

		<!--<xsl:when test="string(count(./node))='0'">-->
                <!-- 1. Ebene mit subnodes -->
		<xsl:when test="(../@name='PAULA') and (string(count(./node))!='0')">
			<xsl:text>\'</xsl:text>
                          <table cellpadding="0" cellspacing="1" border="0">
                            <tr bgcolor="#00378a">
                              <td align="left" valign="top" width="130">
                                <img src="&prefix;/WebFrontend/images/blind.gif" width="1" height="13" alt="" border="0" />
                                <font class="NAV">
			          <xsl:value-of select="@label"/>
                                </font>
                              </td>
                            </tr>
                          </table>
			<xsl:text>\',[</xsl:text>
			<xsl:for-each select="node">
				<xsl:apply-templates select="."/>
				<xsl:if test="not(position()=last())">
					<xsl:text>,</xsl:text>
				</xsl:if>
			</xsl:for-each>
			<xsl:text>]</xsl:text>
		</xsl:when>
                <!-- 1. Ebene ohne subnodes -->
		<xsl:when test="(../@name='PAULA') and (string(count(./node))='0')">
			<xsl:text>\'</xsl:text>
                          <table cellpadding="0" cellspacing="1" border="0">
                            <tr bgcolor="#00378a">
                              <td align="left" valign="top" width="130">
                               <img src="&prefix;/WebFrontend/images/blind.gif" width="1" height="13" alt="" border="0" />
                               <a class="NAV">
                                <xsl:choose>
                                 <xsl:when test="@name='LOGOUT'">
			          <xsl:attribute name="target"><xsl:text>_parent</xsl:text></xsl:attribute>
                                 </xsl:when>
                                 <xsl:otherwise>
			          <xsl:attribute name="target">content</xsl:attribute>
                                 </xsl:otherwise>
                                </xsl:choose>
			          <xsl:attribute name="href">
				    <xsl:text>/paul-getcim?form=</xsl:text>
				    <xsl:value-of select="string(@name)" />
			          </xsl:attribute>
			          <xsl:value-of select="@label"/>
			        </a>
                              </td>
                            </tr>
                          </table>
			<xsl:text>\'</xsl:text>
		</xsl:when>		
                <!-- Hoehere Ebene mit subnodes -->
		<xsl:when test="(../@name!='PAULA') and (string(count(./node))!='0')">
                        <xsl:text>\'</xsl:text>
                            <img src="&prefix;/WebFrontend/images/blind.gif" width="1" height="13" alt="" border="0" />
                            <span class="SNAV">
			    <xsl:value-of select="@label"/>
                            </span>
			<xsl:text>\',[</xsl:text>
			<xsl:for-each select="node">
				<xsl:apply-templates select="."/>
				<xsl:if test="not(position()=last())">
					<xsl:text>,</xsl:text>
				</xsl:if>
			</xsl:for-each>
			<xsl:text>]</xsl:text>
		</xsl:when>
		<xsl:otherwise>
                        <xsl:text>\'</xsl:text>
                        <img src="&prefix;/WebFrontend/images/blind.gif" width="1" height="13" alt="" border="0" />
			<a target="content" class="SNAV">
			    <xsl:attribute name="href">
					<xsl:text>/paul-getcim?form=</xsl:text>
					<xsl:value-of select="string(@name)" />
			    </xsl:attribute>
			    <xsl:value-of select="@label"/>
			</a>
			<xsl:text>\'</xsl:text>
		</xsl:otherwise>

	</xsl:choose>


</xsl:template>
<!-- ___node___________________________________________________________ -->


</xsl:stylesheet>
