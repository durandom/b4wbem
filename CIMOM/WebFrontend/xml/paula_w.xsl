<?xml version="1.0" encoding="iso-8859-1"?>
<!DOCTYPE config [
<!ENTITY prefix "">
<!ENTITY newline '<xsl:text>
</xsl:text>'>
<!ENTITY questionmark '<td align="right">
  <xsl:text>&#160;</xsl:text>
  <xsl:if test="../../docs/help/@name = ./@name">
    <img src="&prefix;/WebFrontend/images/blind.gif" width="15" border="0"/>
    <span style="position:relative">
      <xsl:attribute name="name"><xsl:value-of select="@name"/>Q</xsl:attribute>
      <img border="0" align="absmiddle">
        <xsl:attribute name="src">
        <xsl:text>&prefix;/WebFrontend/images/question1.png?</xsl:text>
        <xsl:value-of select="@name"/>Div</xsl:attribute>
      </img>
    </span>&newline;
    <script language="Javascript"><xsl:text>setTimeout("document.</xsl:text>
      <xsl:value-of select="@name"/>
      <xsl:text>Q.document.captureEvents(Event.MOUSEDOWN)",500);</xsl:text>&newline;
      <xsl:text>setTimeout("document.</xsl:text>
      <xsl:value-of select="@name"/>
      <xsl:text>Q.document.onmousedown=showHelpE",500);</xsl:text>
    </script>&newline;
  </xsl:if>
</td>'>
<!ENTITY insertName '<xsl:attribute name="name">
  <xsl:value-of select="@name"/>
</xsl:attribute>'>
<!ENTITY insertLabel '<xsl:attribute name="value">
  <xsl:value-of select="@label"/>
</xsl:attribute>'>
<!ENTITY blindImage '<img src="&prefix;/WebFrontend/images/blind.gif" height="17" width="1"/>'>
]>

<!--
     Mit Hilfe dieser XSL-Datei koennen xml-Daten in HTML-Daten umgewandelt
     wewrden.
-->
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform" version="1.0">

<xsl:output encoding="iso-8859-1"/>

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
	.hide
	{
		position:relative;
		visibility:hide;
	}
	.show
	{
		position:relative;
		visibility:show;
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
&newline;

    
    <head>&newline;
      <!--<meta http-equiv="Content-Type" content="text/html; charset=iso-8859-1" />-->
      <script language="JavaScript" src="&prefix;/WebFrontend/jscript/forms.js"></script>
      <title>PaulA</title>&newline;
    </head>&newline;
    <body leftmargin="0" topmargin="0" marginwidth="0" marginheight="0">&newline;
    	
	<xsl:apply-templates select="paula/form/docs/help"/>&newline;
	
	<form method="post" action="/paul-setcim" onSubmit="return evalSubmit()" enctype="multipart/form-data">
		<xsl:attribute name="name"><xsl:value-of select="paula/form/@name"/></xsl:attribute>&newline;

	<table border="0" cellspacing="0" cellpadding="10">
		<xsl:attribute name="bgcolor"><xsl:value-of select="$fieldcolor"/></xsl:attribute>&newline;

		<xsl:apply-templates select="paula/form"/>

	</table>&newline;

	</form>&newline;
    </body>&newline;
  </html>&newline;
&newline;
&newline;
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
  	&newline;
  <tr>
    <xsl:attribute name="bgcolor"><xsl:value-of select="$barcolor"/></xsl:attribute>&newline;
    <td colspan="2" align="LEFT">
      <div class="title">
        <nobr>
          <xsl:value-of select="./title" />
        </nobr>
      </div>
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
  &newline;
	<!-- This is just a beta; or not -->
	<xsl:for-each select="./*">
		<xsl:if test="@mandatory">
		    <script>&newline;
		      <xsl:text>mandatories['</xsl:text>
		      <xsl:value-of select="@name"/>
		      <xsl:text>']='1'</xsl:text>&newline;
		    </script>&newline;
		</xsl:if>
	</xsl:for-each>
  
	<xsl:for-each select="./*">
		<xsl:apply-templates select="."/>
		&newline;
		&newline;
	</xsl:for-each>
  
&newline;
</xsl:template> 
<!-- ___components_____________________________________________________ -->



<!-- ___help_____________________________________________________ -->
<xsl:template match="help">
	<div class="help">
		<xsl:attribute name="name"><xsl:value-of select="@name"/>Div</xsl:attribute>
		<xsl:value-of select="."/>
	</div>
&newline;
</xsl:template> 
<!-- ___help_____________________________________________________ -->



<!-- ___actions________________________________________________________ -->
<xsl:template match="actions">
  	&newline;

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
        <input type="hidden" name="ModifiedProperties" value="" />&newline;
        <xsl:if test="not(./action | ./reset)">
          <xsl:text>&#160;</xsl:text>
        </xsl:if>
      </div>&newline;
    </td>&newline;
  </tr>
&newline;
</xsl:template> 
<!-- ___actions________________________________________________________ -->



<!-- ___submit_________________________________________________________ -->
<xsl:template match="submit">
  	&newline;

  <input type="submit" onClick="return generalSubmit()">
    &insertLabel;
  </input>&newline;
&newline;
</xsl:template>
<!-- ___submit_________________________________________________________ -->



<!-- ___reset_________________________________________________________ -->
<xsl:template match="reset">
  	&newline;

  <input type="reset">
    &insertLabel;
  </input>&newline;
&newline;
</xsl:template>
<!-- ___submit_________________________________________________________ -->



<!-- ___action_________________________________________________________ -->
<xsl:template match="action">
  	&newline;

  <input type="button">
    
    <!-- Zwingendes Attribut Name einsetzen! -->
    &insertName;

    <!-- Die beschriftung des Buttons steht wie bei anderen Elementen im "label"! -->
    &insertLabel;

    <xsl:if test="string(@do)=''">
      <xsl:attribute name="ONCLICK">
        <xsl:value-of select="@do"/>
      </xsl:attribute>
    </xsl:if>
  </input>&newline;
  <xsl:text>&#160;</xsl:text>
&newline;
</xsl:template>                                                                
<!-- ___action_________________________________________________________ -->
                                                  



<!-- 
#######################################################################

	Hier beginnen die Definitionen der "Visuellen"-Elemente

#######################################################################
-->


<!--
	Tja, mal sehen, ob wir diese selectgroups noch benutzen können - sie
	funktionieren jedenfalls noch nicht, da DIVs nur für eigene FORMs ein und
	ausgeblendet werden können und da wir bisher mit einer einzigen FORM
	arbeiten, können wir das erstmal knicken...
-->

<!-- ___selectgroup____________________________________________________ -
<xsl:template match="selectgroup">
<tr>
  	&newline;

  <td valign="top">
    <span class="content">
      <xsl:value-of select="@label"/>
      &blindImage;
    </span>
  </td>

  	&newline;
  
  <td colspan="1" align="left">
  <xsl:for-each select="./group">
    <span class="content">
      <input type="radio">
      
        !- Zwingendes Attribut "name" einsetzen! Tree beachten!!! -
        <xsl:attribute name="name"><xsl:value-of select="../@name"/></xsl:attribute>
        <xsl:attribute name="value"><xsl:value-of select="@value"/></xsl:attribute>
        
        <xsl:if test="../@value=@value">
           <xsl:attribute name="checked"/>
        </xsl:if>
        
        !- Wenn eine Beschriftung angegeben wird, sollte sie nicht umgebrochen werden! -
        <xsl:if test="not(string(@label)='')">
          <nobr><xsl:value-of select="@label"/></nobr>
        </xsl:if>
	
      </input>
    </span>

    <xsl:if test="not(position()=last())">
      <br/>
    </xsl:if>
    
  </xsl:for-each>
  </td>
  &questionmark;

</tr>&newline;

<tr>&newline;
<td colspan="3">
!-
  <xsl:for-each select="./group">
-
  <div syle="position:relative;color:red;visibility:hidden">
    <form>
    <table>
      <tr>
	&insertName;
	<input type="text" value="kujkjh"/>
	!-
	<xsl:if test="not(../@value=@value)">
	  <xsl:attribute name="class">show</xsl:attribute>
	</xsl:if>
	<xsl:if test="../@value=@value">
	  <xsl:attribute name="class">show</xsl:attribute>
	</xsl:if>
	<xsl:apply-templates select="./*"/>
	-
	&newline;
      </tr>
    </table>
    </form>
  </div>&newline;
!-
  </xsl:for-each>&newline;
-
</td>
</tr>
&newline;
</xsl:template>                                                                
!- ___selectgroup____________________________________________________ -->
                                                  


<!-- ___inputrange_____________________________________________________ -->
<xsl:template match="inputrange">
<tr>
  	&newline;
  <xsl:if test="not(string(@label)='')">
    <td valign="top" colspan="3">
      <div class="content">
        <xsl:value-of select="@label"/>
        &blindImage;
      </div>
    </td>
  </xsl:if>&newline;
  
  <tr>
  <td>&#160;</td>&newline;	<!-- just keep formatting-style -->
  <td>&newline;

    <span class="content">&newline;
      <xsl:for-each select="./*">	<!-- rangestart/-end -->
        
	<!-- set the appropriate label (text) -->
	<xsl:if test="name()='rangestart'"><xsl:value-of select="../@startLabel"/></xsl:if>
	<xsl:if test="name()='rangeend'"  ><xsl:value-of select="../@endLabel"  /></xsl:if>

        <input type="text" size="11" maxlength="11">
	  
	  <!-- attribute 'name' should be one of "<..>Start" "<...>End" -->
	  <xsl:attribute name="name">
	    <xsl:value-of select="../@name"/>
	    <xsl:if test="name()='rangestart'"><xsl:text>Start</xsl:text></xsl:if>
	    <xsl:if test="name()='rangeend'"  ><xsl:text>End</xsl:text></xsl:if>
	  </xsl:attribute>
	  
          <!-- content of the input field has to be in attribute "value" - even if it's empty -->
          <xsl:attribute name="value"><xsl:value-of select="."/></xsl:attribute>
	  
	  <!-- produce for eg. a "ONCHANGE=changeRange( 'ExtensionRange', 0, 'FaxMinExt' )" -->
          <xsl:attribute name="ONCHANGE">
	    <xsl:text>changeRange( '</xsl:text>
	    <xsl:value-of select="../@name"/>
	    <xsl:text>', </xsl:text>
	    <xsl:if test="name()='rangestart'"><xsl:text>0</xsl:text></xsl:if>
	    <xsl:if test="name()='rangeend'"><xsl:text>1</xsl:text></xsl:if>
	    <xsl:text> )</xsl:text>		<!-- 0 changes start-value, 1 changes end-value -->
          </xsl:attribute>

        </input>&newline;
        
      </xsl:for-each>&newline;
    </span>&newline;
    
  <input type="hidden">&insertName;
    <xsl:attribute name="value">
      <xsl:value-of select="./rangestart/."/>
      <xsl:text>::</xsl:text>
      <xsl:value-of select="./rangeend/."/>
    </xsl:attribute>
  </input>&newline;
    <script>&newline;
      <xsl:text>propArr['</xsl:text>
      <xsl:value-of select="@name"/>
      <xsl:text>']='</xsl:text>
      <xsl:value-of select="./rangestart/."/>
      <xsl:text>::</xsl:text>
      <xsl:value-of select="./rangeend/."/>
      <xsl:text>'</xsl:text>&newline;
    </script>&newline;
  </td>&newline;
  &questionmark;
  </tr>&newline;
</tr>
&newline;
</xsl:template>
<!-- ___inputrange_____________________________________________________ -->
                                                  




<!-- ___externalLink___________________________________________________ -->
<xsl:template match="externalLink">
<tr>
  	&newline;

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
                                                  


<!-- ___filerequest____________________________________________________ -->
<xsl:template match="filerequest">
<tr>
  	&newline;

  <td>
    <div class="content">
      <xsl:value-of select="@label"/>
    </div>
  </td>
  	&newline;

  <td>
    <span class="content">
      <input type="file">
        &insertName;
      </input>&newline;
    </span>
  </td>
  &questionmark;
</tr>
&newline;
</xsl:template>                                                                
<!-- ___action_________________________________________________________ -->
                                                  

<!-- __hiddenfield_____________________________________________________ -->
<xsl:template match="hiddenfield">

  &newline;
  <input type="hidden">
    <xsl:attribute name="name">
      <xsl:value-of select="@name"/>
    </xsl:attribute>
    <xsl:attribute name="value">
      <xsl:value-of select="@value"/>
    </xsl:attribute>
  </input>&newline;
&newline;
</xsl:template>
<!-- ___hiddenfield_____________________________________________________ -->                                             


<!-- ___text___________________________________________________________ -->
<xsl:template match="text">
<tr>
  &newline;
  <td colspan="2">
    <span class="content">
      <xsl:value-of select="."/>
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
  	&newline;
  <td>
    <span class="content">
      <xsl:value-of select="@label"/>
    </span>
  </td>
  	&newline;
  <td>
    <span class="content">
      <input type="text" size="30">
        <!-- Zwingendes Attribut Name einsetzen! -->
        &insertName;
        
        <!-- Vorgabetext wird ins Attribut "value" eingesetzt -->
        <xsl:if test="not(string(.)='')">
          <xsl:attribute name="value"><xsl:value-of select="."/></xsl:attribute>
        </xsl:if>
      </input>&newline;
      <script>
        <xsl:text>propArr['</xsl:text>
        <xsl:value-of select="@name"/>
        <xsl:text>']='</xsl:text>
        <xsl:value-of select="."/>
        <xsl:text>'</xsl:text>
      </script>&newline;
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
  	&newline;

  <td valign="top">
    <div class="content">
      <br/><xsl:value-of select="@label"/>
    </div>
  </td>
  	&newline;

  <td>
    <span class="content">
      <textarea cols="30" rows="5" wrap="">
        &insertName;		
        
        <!-- Vorgabetext wird zwischen den Tags eingesetzt -->
        <xsl:value-of select="."/>
      </textarea>
      <script>
        <xsl:text>propArr['</xsl:text>
        <xsl:value-of select="@name"/>
        <xsl:text>']=document.forms[0].</xsl:text>
        <xsl:value-of select="@name"/>
        <xsl:text>.value</xsl:text>
      </script>
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
  	&newline;

  <td valign="top">
    <div class="content">
      <br/><xsl:value-of select="@label" />
    </div>
  </td>
  	&newline;

  <td>
    <div class="content">
      <input type="password" size="30">
        <!-- Zwingendes Attribut Name einsetzen! -->
        &insertName;
      </input>&newline;
      <br/>
      <input type="password" size="30">
        <!-- Zwingendes Attribut Name einsetzen + "2" ! -->
        <xsl:attribute name="name">
          <xsl:value-of select="@name"/>
          <xsl:text>Sec</xsl:text>
        </xsl:attribute>
      </input>&newline;
      <script>
        <xsl:text>propArr['</xsl:text>
        <xsl:value-of select="@name"/>
        <xsl:text>']='</xsl:text>
        <xsl:value-of select="."/>
        <xsl:text>'</xsl:text>
      </script>&newline;
    </div>
  </td>
  &questionmark;
</tr>
&newline;
</xsl:template>                                                                
<!-- ___password_______________________________________________________ -->
                                                  



<!-- ___inputtime______________________________________________________ -->
<xsl:template match="inputtime">
<tr>
  	&newline;

  <td>
    <div class="content">
      <xsl:value-of select="@label"/>
    </div>
  </td>
  	&newline;

  <td>
    <div class="content">
      <input type="text" size="5" maxlength="5">
        <!-- Zwingendes Attribut Name einsetzen! -->
        &insertName;

        <!-- Vorgabetext wird ins Attribut "value" eingesetzt -->
        <xsl:if test="not(string(.)='')">
          <xsl:attribute name="value"><xsl:value-of select="."/></xsl:attribute>
        </xsl:if>
      </input>&newline;
      <script>
        <xsl:text>propArr['</xsl:text>
        <xsl:value-of select="@name"/>
        <xsl:text>']='</xsl:text>
        <xsl:value-of select="."/>
        <xsl:text>'</xsl:text>
      </script>&newline;
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
  	&newline;

  <td>
    <div class="content">
      <xsl:value-of select="@label"/>
    </div>
  </td>
  	&newline;

  <td>
    <span class="content">
      <input type="text" size="11" maxlength="11">
        <!-- Zwingendes Attribut Name einsetzen! -->
        &insertName;
      
        <!-- Vorgabetext wird ins Attribut "value" eingesetzt -->
        <xsl:if test="not(string(.)='')">
          <xsl:attribute name="value"><xsl:value-of select="."/></xsl:attribute>
        </xsl:if>
      </input>&newline;
      <script>
        <xsl:text>propArr['</xsl:text>
        <xsl:value-of select="@name"/>
        <xsl:text>']='</xsl:text>
        <xsl:value-of select="."/>
        <xsl:text>'</xsl:text>
      </script>&newline;
    </span>
  </td>
  &questionmark;
  &newline;
</tr>
&newline;
</xsl:template>
<!-- ___inputvalue_____________________________________________________ -->
                                                  


<!-- ___singleselect___________________________________________________ -->
<xsl:template match="singleselect">
<tr>

  	&newline;

  <td valign="top">
    <span class="content">
      <xsl:value-of select="@label"/>
      &blindImage;
    </span>
  </td>
  	&newline;
  <td>
    <xsl:choose>
      
      <xsl:when test="count(./*)=0">
        <xsl:text>&#160;</xsl:text>
      </xsl:when>
      
      <xsl:when test="count(./*)&lt;4">
        <xsl:for-each select="./*">	<!-- default? & choice* -->
        
        <span class="content">
          <input type="radio">
            <!-- Zwingendes Attribut "name" einsetzen! Tree beachten!!! -->
            <xsl:attribute name="name"><xsl:value-of select="../@name"/></xsl:attribute>
            <xsl:attribute name="value"><xsl:value-of select="@value"/></xsl:attribute>

            <xsl:if test="(name()='default')">
              <xsl:attribute name="checked"/>
            </xsl:if>
                        
             <!-- Wenn eine Beschriftung angegeben wird, sollte sie nicht umgebrochen werden! -->
             <xsl:if test="not(string(.)='')">
               <nobr><xsl:value-of select="."/></nobr>
             </xsl:if>
           </input>&newline;
         </span>

         <xsl:if test="not(position()=last())">
           <br/>
         </xsl:if>
       </xsl:for-each>
       <script>
         <xsl:text>propArr['</xsl:text>
         <xsl:value-of select="@name"/>
         <xsl:text>']='</xsl:text>
         <xsl:value-of select="./default/@value"/>
         <xsl:text>'</xsl:text>
       </script>
     </xsl:when>
     
     <xsl:otherwise>
       <div class="content">
         <select>
           <!-- Zwingendes Attribut "name" einsetzen -->		
           &insertName;

           <xsl:attribute name="size">1</xsl:attribute>
           
           <!-- Kann nur default & choice sein! -->
           <xsl:apply-templates select="./*"/>
	   
         </select>&newline;

         <script>
           <xsl:text>propArr['</xsl:text>
           <xsl:value-of select="@name"/>
           <xsl:text>']='</xsl:text>
           <xsl:value-of select="./default/@value"/>
           <xsl:text>'</xsl:text>
         </script>
       </div>
     </xsl:otherwise>
     
   </xsl:choose>
 </td>
 &questionmark;
</tr>
&newline;
</xsl:template>
<!-- ___singleselect___________________________________________________ -->


<!-- ___permissionselect_______________________________________________ -->
<xsl:template match="permissionselect">
<tr>
  	&newline;

  <td valign="top">
    <span class="content">
      <xsl:value-of select="@label"/>
    </span>
    &blindImage;
  </td>
  	&newline;

  <td>
    <span class="content">
      <select>
        <!-- Zwingendes Attribut "name" einsetzen -->		
        &insertName;
        <xsl:attribute name="size">1</xsl:attribute>
	
	<xsl:attribute name="ONCHANGE">
		<xsl:text>changePermission( '</xsl:text>
		<xsl:value-of select="@name"/>
		<xsl:text>' )</xsl:text>
        </xsl:attribute>
	
        <!-- Kann nur default & choice sein! -->
        <xsl:apply-templates select="./*"/>
      </select>
         	&newline;
    </span>
  </td>
  &questionmark;
</tr>
&newline;
</xsl:template>
<!-- ___permissionselect_______________________________________________ -->


<!-- ___default________________________________________________________ -->
<xsl:template match="default">
  	&newline;

  <option>
    <xsl:attribute name="selected"/>
    <xsl:attribute name="value">
      <xsl:choose>
        <xsl:when test="./@value">
          <xsl:value-of select="./@value"/>
        </xsl:when>
        <xsl:otherwise>
          <xsl:value-of select="."/>
        </xsl:otherwise>
      </xsl:choose>
    </xsl:attribute>
    <xsl:value-of select="."/>
  </option>
&newline;
</xsl:template>
<!-- ___default________________________________________________________ -->



<!-- ___choice_________________________________________________________ -->
<xsl:template match="choice">
  	&newline;

  <option>
    <xsl:attribute name="value">
      <xsl:choose>
        <xsl:when test="./@value">
          <xsl:value-of select="./@value"/>
        </xsl:when>
        <xsl:otherwise>
          <xsl:value-of select="."/>
        </xsl:otherwise>
      </xsl:choose>
    </xsl:attribute>
    <xsl:value-of select="."/>
  </option>
&newline;
</xsl:template>
<!-- ___choice_________________________________________________________ -->



<!-- ___boolselect_____________________________________________________ -->
<xsl:template match="boolselect">
<tr>
  	&newline;

  <td>
    <div class="content">
      <xsl:value-of select="@label"/>
    </div>
  </td>
  	&newline;

  <td>
    <div class="content">
      <input type="checkbox">
        &insertName;
        <xsl:attribute name="onclick">
          <xsl:text>toggleCheckboxValue('</xsl:text>
          <xsl:value-of select="@name" />
            <xsl:text>')</xsl:text>
        </xsl:attribute>
	<xsl:choose>
          <xsl:when test="@value='1'">
            <xsl:attribute name="checked" />
            <xsl:attribute name="value">1</xsl:attribute>  
          </xsl:when>
          <xsl:when test="@value='0'">
            <xsl:attribute name="value">0</xsl:attribute>  
          </xsl:when>
	  <xsl:otherwise>
            <xsl:attribute name="value"><xsl:value-of select="@value"/></xsl:attribute>
	  </xsl:otherwise>
	</xsl:choose>
          
        <!-- Wenn eine Beschriftung angegeben wird, sollte sie nicht umgebrochen werden! -->
        <xsl:if test="not(string(.)='')">
          <nobr><xsl:value-of select="."/></nobr>
        </xsl:if>
      </input>&newline;

      <script>
        <xsl:text>propArr['</xsl:text>
        <xsl:value-of select="@name"/>
        <xsl:text>']=''</xsl:text>
      </script>&newline;
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
  	&newline;


  <td>
    <div class="content">
      <xsl:value-of select="@label"/>
    </div>
  </td>
  	&newline;

  <td>
      <xsl:variable name="ip1"><xsl:value-of select="substring-before(string(.),'.')"/></xsl:variable>
      <xsl:variable name="rest1"><xsl:value-of select="substring-after(string(.),'.')"/></xsl:variable>
      
      <xsl:variable name="ip2"><xsl:value-of select="substring-before(string($rest1),'.')"/></xsl:variable>
      <xsl:variable name="rest2"><xsl:value-of select="substring-after(string($rest1),'.')"/></xsl:variable>
      
      <xsl:variable name="ip3"><xsl:value-of select="substring-before(string($rest2),'.')"/></xsl:variable>
      <xsl:variable name="ip4"><xsl:value-of select="substring-after(string($rest2),'.')"/></xsl:variable>
      
      <div class="content">
        <input type="text" size="3" maxlength="3">
          <xsl:attribute name="name"><xsl:value-of select="@name"/>1</xsl:attribute>
          <xsl:attribute name="value"><xsl:value-of select="$ip1"/></xsl:attribute>
          <xsl:attribute name="ONCHANGE">updateIP('<xsl:value-of select="@name"/>1')</xsl:attribute>
        </input>&newline;
        
        <xsl:text>.</xsl:text>
        <input type="text" size="3" maxlength="3">
          <xsl:attribute name="name"><xsl:value-of select="@name"/>2</xsl:attribute>
          <xsl:attribute name="value"><xsl:value-of select="$ip2"/></xsl:attribute>
          <xsl:attribute name="ONCHANGE">updateIP('<xsl:value-of select="@name"/>2')</xsl:attribute>
        </input>&newline;
        
        <xsl:text>.</xsl:text>
        <input type="text" size="3" maxlength="3">
          <xsl:attribute name="name"><xsl:value-of select="@name"/>3</xsl:attribute>
          <xsl:attribute name="value"><xsl:value-of select="$ip3"/></xsl:attribute>
          <xsl:attribute name="ONCHANGE">updateIP('<xsl:value-of select="@name"/>3')</xsl:attribute>
        </input>&newline;

        <xsl:text>.</xsl:text>
        <input type="text" size="3" maxlength="3">
          <xsl:attribute name="name"><xsl:value-of select="@name"/>4</xsl:attribute>
          <xsl:attribute name="value"><xsl:value-of select="$ip4"/></xsl:attribute>
          <xsl:attribute name="ONCHANGE">updateIP('<xsl:value-of select="@name"/>4')</xsl:attribute>
        </input>&newline;
      </div>

    <input type="hidden">
          <xsl:attribute name="name"><xsl:value-of select="@name"/></xsl:attribute>
          <xsl:attribute name="value"><xsl:value-of select="."/></xsl:attribute>
    </input>&newline;
    <script>
      <xsl:text>propArr['</xsl:text>
      <xsl:value-of select="@name"/>
      <xsl:text>']='</xsl:text>
      <xsl:value-of select="." />
      <xsl:text>'</xsl:text>
    </script>&newline;
  </td>
  &questionmark;
</tr>
&newline;
</xsl:template>                                                                
<!-- ___inputIP________________________________________________________ -->


                                                  
<!-- ___permissionlist_________________________________________________ -->
<xsl:template match="permissionlist">
	&newline;

	<xsl:for-each select="./*">
		<xsl:apply-templates select="."/>	<!-- permissionselect -->
	</xsl:for-each>


      <input type="hidden">
        <xsl:attribute name="name">
          <xsl:value-of select="./@name"/>	<!-- sollte permissions sein -->
        </xsl:attribute>
	
        <xsl:attribute name="value">
	  <xsl:for-each select="./permissionselect/default">
	    <!-- create <perm>_<r|w|n>::... -->
	    <xsl:value-of select="../@name"/><xsl:text>_</xsl:text><xsl:value-of select="@value"/>
	    <xsl:if test="not(position()=last())">
              <xsl:text>::</xsl:text>
	    </xsl:if>
	  </xsl:for-each>
        </xsl:attribute>
      </input>&newline;


  <script>
    <!-- create propArr['permissions']='<perm1>_<r|w|n>::<...> ... ' -->
    
    <xsl:text>propArr['</xsl:text>
    <xsl:value-of select="@name"/>
    <xsl:text>']='</xsl:text>
    
    <xsl:for-each select="./permissionselect/default">
      <!-- create <perm>_<r|w|n>::... -->
      <xsl:value-of select="../@name"/><xsl:text>_</xsl:text><xsl:value-of select="@value"/>
      <xsl:if test="not(position()=last())">
        <xsl:text>::</xsl:text>
      </xsl:if>
    </xsl:for-each>
    
    <xsl:text>'</xsl:text>
    
  </script>

&newline;
</xsl:template>                                                              
<!-- ___permissionlist_________________________________________________ -->



<!-- ___editlist_______________________________________________________ -->
<xsl:template match="editlist">
	<xsl:if test="not(string(@label)='')">
	<tr>
		<td valign="top" colspan="3">
			<div class="content">
			<xsl:value-of select="@label"/>
			&blindImage;
			</div>
		</td>
	</tr>
	</xsl:if>

<tr>
	<td>
		<span class="content">&newline;
			<input type="button" value="Hinzuf&#252;gen" name="addbutton">
				<xsl:attribute name="ONCLICK">
				  <xsl:text>addItemToEdList('</xsl:text>
				  <xsl:value-of select="./list[1]/@name" />
				  <xsl:text>')</xsl:text>
				</xsl:attribute>
			</input>&newline;
		</span>&newline;
	</td>&newline;

	<td>&newline;
		<span class="content">
			<input type="text" size="20" name="editfield">
				<xsl:attribute name="ONCHANGE">
				  <xsl:text>addItemToEdList('</xsl:text>
				  <xsl:value-of select="./list[1]/@name" />
				  <xsl:text>')</xsl:text>
				</xsl:attribute>
			</input>&newline;
		</span>&newline;
	</td>&newline;

	<!-- Fragezeichen mit anderer Knotenposition! -->
	<td align="right">
	<xsl:if test="../../docs/help/@name = list/@name">
		<img src="&prefix;/WebFrontend/images/blind.gif" width="15" border="0"/>
		<span style="position:relative">
			<xsl:attribute name="name"><xsl:value-of select="list/@name"/><xsl:text>Q</xsl:text></xsl:attribute>
			
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
			<xsl:value-of select="list/@name"/>
			<xsl:text>Q.document.captureEvents(Event.MOUSEDOWN)",500);</xsl:text>&newline;
			<xsl:text>setTimeout("document.</xsl:text>
			<xsl:value-of select="list/@name"/>
			<xsl:text>Q.document.onmousedown=showHelpE",500);</xsl:text>
		</script>&newline;
	</xsl:if>
	</td>&newline;
</tr>&newline;

<tr>&newline;

    <td valign="top">&newline;
      <div class="content">&newline;
        <input type="button" value="Editieren">
          <xsl:attribute name="ONCLICK">
            <xsl:text>editItemInEdList('</xsl:text>
            <xsl:value-of select="./list[1]/@name" />
            <xsl:text>')</xsl:text>
          </xsl:attribute>
        </input>&newline;
        <br/>&newline;
        <input type="button" value="Loeschen">
          <xsl:attribute name="ONCLICK">
            <xsl:text>removeItemFromEdList('</xsl:text>
            <xsl:value-of select="./list[1]/@name" />
            <xsl:text>')</xsl:text>
          </xsl:attribute>
        </input>&newline;
      </div>&newline;
    </td>&newline;

    <td colspan="2">
      <div class="content">
        <xsl:apply-templates select="./list"/>
      </div>
    </td>&newline;

</tr>&newline;

&newline;
</xsl:template>
<!-- ___editlist_______________________________________________________ -->



<!-- ___list___________________________________________________________ -->
<xsl:template match="list">
  	&newline;
	<select name="editlist" size="8" multiple="">
		<xsl:apply-templates select="./member"/>
	</select>&newline;

	<input type="hidden">&insertName;
		<xsl:attribute name="value">
			<xsl:for-each select="./member">
				<xsl:value-of select="." />
				<xsl:if test="not(position()=last())">
					<xsl:text>::</xsl:text>
				</xsl:if>
			</xsl:for-each>
		</xsl:attribute>
	</input>&newline;
	<script>&newline;
		<xsl:text>propArr['</xsl:text>
		<xsl:value-of select="@name"/>
		<xsl:text>']='</xsl:text>
		<xsl:for-each select="./member">
			<xsl:value-of select="." />
			<xsl:if test="not(position()=last())">
				<xsl:text>::</xsl:text>
			</xsl:if>
		</xsl:for-each>
		<xsl:text>'</xsl:text>
	</script>&newline;

&newline;
</xsl:template>
<!-- ___list___________________________________________________________ -->



<!-- ___member_________________________________________________________ -->
<xsl:template match="member">
  	&newline;
  <option>
    <xsl:attribute name="value">
      <xsl:value-of select="."/>
    </xsl:attribute>
    <xsl:value-of select="."/>
  </option>
&newline;
</xsl:template>
<!-- ___member_________________________________________________________ -->




<!-- ___exchangelist___________________________________________________ -->
<xsl:template match="exchangelist">
  	&newline;
<tr>
	<xsl:for-each select="./list">
		<td>
			<span class="content">
				<img src="&prefix;/WebFrontend/images/blind.gif" width="5" height="15" border="0" />
				<xsl:text><xsl:value-of select="@label"/></xsl:text>
			</span>
		</td>
		<xsl:if test="not(position()=last())">
			<td>&#160;</td>
		</xsl:if>
	</xsl:for-each>
</tr>&newline;

<tr>&newline;

    <td align="center">
      <span class="content">
        <img src="&prefix;/WebFrontend/images/blind.gif" width="5" height="1" border="0" />
        	&newline;

        <select size="8" multiple="">
          <xsl:attribute name="name">selectlist</xsl:attribute>
          <xsl:apply-templates select="./list[1]/member"/>
        </select>
        <img src="&prefix;/WebFrontend/images/blind.gif" width="5" height="1" border="0" />
      </span>
      	&newline;

      <input type="hidden">
        <xsl:attribute name="name">
          <xsl:value-of select="./list[1]/@name"/>
        </xsl:attribute>
        <xsl:attribute name="value">
          <xsl:for-each select="./list[1]/member">
            <xsl:value-of select="." />
            <xsl:if test="not(position()=last())">
              <xsl:text>::</xsl:text>
            </xsl:if>
          </xsl:for-each>
        </xsl:attribute>
      </input>&newline;
      <script>
        <xsl:text>propArr['</xsl:text>
        <xsl:value-of select="./list[1]/@name"/>
        <xsl:text>']='</xsl:text>
        <xsl:for-each select="./list[1]/member">
          <xsl:value-of select="." />
          <xsl:if test="not(position()=last())">
            <xsl:text>::</xsl:text>
          </xsl:if>
        </xsl:for-each>
        <xsl:text>'</xsl:text>
      </script>
    </td>
    	&newline;

    <xsl:call-template name="exchangebuttons"/>
    	&newline;

    <td align="center">
      <span class="content">
        <img src="&prefix;/WebFrontend/images/blind.gif" width="5" height="1" border="0" />
        <select size="8" multiple="">
          <xsl:attribute name="name">completelist</xsl:attribute>
          <xsl:apply-templates select="./list[2]/member"/>
        </select>
      </span>
      
      <!-- Fragezeichen, allerdings mittig positioniert! -->
      <xsl:if test="../../docs/help/@name = @name">
        <img src="&prefix;/WebFrontend/images/blind.gif" width="15" height="1" border="0" />
        <span style="position:relative">
          <xsl:attribute name="name"><xsl:value-of select="@name"/>Q</xsl:attribute>
          <img border="0" align="absmiddle">
            <xsl:attribute name="src">
              <xsl:text>&prefix;/WebFrontend/images/question1.png?</xsl:text>
              <xsl:value-of select="@name"/>
              <xsl:text>Div</xsl:text>
            </xsl:attribute>
          </img>
        </span>
        <script language="Javascript">
          <xsl:text>setTimeout("document.</xsl:text>
          <xsl:value-of select="@name"/>
          <xsl:text>Q.document.captureEvents(Event.MOUSEDOWN)",500);</xsl:text>
          <xsl:text>setTimeout("document.</xsl:text>
          <xsl:value-of select="@name"/>
          <xsl:text>Q.document.onmousedown=showHelpE",500);</xsl:text>
        </script>
      </xsl:if>
		
    </td>&newline;

</tr>
&newline;
</xsl:template>
<!-- ___exchangelist___________________________________________________ -->



<!-- ___exchangebuttons________________________________________________ -->
<xsl:template name="exchangebuttons">
  	&newline;

  <td align="center" valign="middle">
    <div class="content">
      <input type="button" value="&lt;--Alle">
        <xsl:attribute name="ONCLICK">
          <xsl:text>addAllToExList('</xsl:text>
          <xsl:value-of select="./list[1]/@name" />
          <xsl:text>')</xsl:text>
        </xsl:attribute>
      </input>&newline;
    </div>
    <div class="content">
      <input type="button" value="&lt;--">
        <xsl:attribute name="ONCLICK">
          <xsl:text>addItemToExList('</xsl:text>
          <xsl:value-of select="./list[1]/@name" />
          <xsl:text>')</xsl:text>
        </xsl:attribute>
      </input>&newline;
    </div>
    <div class="content">
      <input type="button" value="--&gt;">
        <xsl:attribute name="ONCLICK">
          <xsl:text>removeItemFromExList('</xsl:text>
          <xsl:value-of select="./list[1]/@name" />
          <xsl:text>')</xsl:text>
        </xsl:attribute>
      </input>&newline;
    </div>
    <div class="content">
      <input type="button" value="Alle--&gt;">
        <xsl:attribute name="ONCLICK">
          <xsl:text>removeAllFromExList('</xsl:text>
          <xsl:value-of select="./list[1]/@name" />
          <xsl:text>')</xsl:text>
        </xsl:attribute>
      </input>&newline;
    </div>
  </td>
&newline;
</xsl:template>
<!-- ___exchangebuttons________________________________________________ -->



<!-- ___editIPlist_____________________________________________________ -->
<xsl:template match="editIPlist">

<xsl:if test="not(string(@label)='')">
	<tr>&newline;
		<td valign="top">
			<xsl:value-of select="@label"/>
		</td>
	</tr>
</xsl:if>&newline;

<tr>&newline;
  <td>&newline;
    <div class="content">&newline;
      <input type="button" value="Hinzuf&#252;gen">
        <xsl:attribute name="ONCLICK">
          <xsl:text>addItemToIPList('</xsl:text>
          <xsl:value-of select="./list[1]/@name" />
          <xsl:text>')</xsl:text>
        </xsl:attribute>
      </input>
    </div>&newline;
  </td>&newline;

  <td colspan="2">
    <span class="content">
      <input type="text" size="3" maxlength="3" name="ip1" onBlur="validateIP('ip1')" />&newline;
      <xsl:text>.</xsl:text>&newline;
      <input type="text" size="3" maxlength="3" name="ip2" onBlur="validateIP('ip2')" />&newline;
      <xsl:text>.</xsl:text>&newline;
      <input type="text" size="3" maxlength="3" name="ip3" onBlur="validateIP('ip3')" />&newline;
      <xsl:text>.</xsl:text>&newline;
      <input type="text" size="3" maxlength="3" name="ip4" onBlur="validateIP('ip4')" />&newline;
    </span>
    
    <!-- Fragezeichen mit anderer Knotenposition! -->
    <xsl:if test="../../docs/help/@name = list/@name">
      <img src="&prefix;/WebFrontend/images/blind.gif" width="15" border="0"/>&newline;
      <span style="position:relative">
        <xsl:attribute name="name"><xsl:value-of select="list/@name"/>Q</xsl:attribute>&newline;
        <img border="0">
          <xsl:attribute name="src">
            <xsl:text>&prefix;/WebFrontend/images/question1.png?</xsl:text>
            <xsl:value-of select="list/@name"/>Div</xsl:attribute>
          </img>&newline;
        </span>&newline;
        <script language="Javascript">
          <xsl:text>setTimeout("document.</xsl:text>
          <xsl:value-of select="list/@name" />
          <xsl:text>Q.document.captureEvents(Event.MOUSEDOWN)",500);</xsl:text>
          <xsl:text>setTimeout("document.</xsl:text>
          <xsl:value-of select="list/@name"/>
          <xsl:text>Q.document.onmousedown=showHelpE",500);</xsl:text>
        </script>&newline;
      </xsl:if>
    <!-- -->
  </td>&newline;
</tr>&newline;

<tr>&newline;
    <td valign="top">
      <div class="content">
        <input type="button" value="Editieren">
          <xsl:attribute name="ONCLICK">
            <xsl:text>editItemInIPList('</xsl:text>
            <xsl:value-of select="./list[1]/@name" />
            <xsl:text>')</xsl:text>
          </xsl:attribute>
        </input>&newline;
        <br/>
        <input type="button" value="Loeschen">
          <xsl:attribute name="ONCLICK">
            <xsl:text>removeItemFromIPList('</xsl:text>
            <xsl:value-of select="./list[1]/@name" />
            <xsl:text>')</xsl:text>
          </xsl:attribute>
        </input>&newline;
      </div>&newline;
    </td>&newline;

    <td colspan="2">
      <div class="content">
        <xsl:apply-templates select="./list"/>
      </div>
    </td>&newline;

</tr>&newline;
</xsl:template>
<!-- ___editIPlist_____________________________________________________ -->



<!-- ___editIPIPlist___________________________________________________ -->
<xsl:template match="editIPIPlist">

<tr>&newline;

	
  <td>&#160;</td>
  <td><div class="content">IP-Startadresse</div></td>
  <td><div class="content">IP-Endadresse (optional)</div></td>
  	&newline;
</tr>&newline;
<tr>&newline;
    	

    <td>&newline;
      <div class="content">&newline;
        <input type="button" value="Hinzuf&#252;gen">
          <xsl:attribute name="ONCLICK">
            <xsl:text>addItemToIPIPList('</xsl:text>
            <xsl:value-of select="./list[1]/@name" />
            <xsl:text>')</xsl:text>
          </xsl:attribute>
        </input>&newline;
      </div>&newline;
    </td>&newline;

    <td>&newline;
      <div class="content">&newline;
        <input type="text" size="3" maxlength="3" name="ips1" onBlur="validateIP('ips1')" />&newline;
        <xsl:text>.</xsl:text>&newline;
        <input type="text" size="3" maxlength="3" name="ips2" onBlur="validateIP('ips2')" />&newline;
        <xsl:text>.</xsl:text>&newline;
        <input type="text" size="3" maxlength="3" name="ips3" onBlur="validateIP('ips3')" />&newline;
        <xsl:text>.</xsl:text>&newline;
        <input type="text" size="3" maxlength="3" name="ips4" onBlur="validateIP('ips4')" />&newline;
      </div>&newline;
    </td>&newline;

    <td>&newline;
      <div class="content">&newline;
        <input type="text" size="3" maxlength="3" name="ipe1" onBlur="validateIP('ipe1')" />&newline;
        <xsl:text>.</xsl:text>&newline;
        <input type="text" size="3" maxlength="3" name="ipe2" onBlur="validateIP('ipe2')" />&newline;
        <xsl:text>.</xsl:text>&newline;
        <input type="text" size="3" maxlength="3" name="ipe3" onBlur="validateIP('ipe3')" />&newline;
        <xsl:text>.</xsl:text>&newline;
        <input type="text" size="3" maxlength="3" name="ipe4" onBlur="validateIP('ipe4')" />&newline;
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
            </img>&newline;
          </span>
          <script language="Javascript">
            <xsl:text>setTimeout("document.</xsl:text>
            <xsl:value-of select="list/@name" />
            <xsl:text>Q.document.captureEvents(Event.MOUSEDOWN)",500);</xsl:text>&newline;
            <xsl:text>setTimeout("document.</xsl:text>
            <xsl:value-of select="list/@name" />
            <xsl:text>Q.document.onmousedown=showHelpE",500);</xsl:text>
          </script>&newline;
        </xsl:if>
      </div>&newline;
    </td>&newline;

</tr>&newline;

<tr>&newline;
    <td valign="top">&newline;
      <div class="content">&newline;
        <input type="button" value="Editieren">
          <xsl:attribute name="ONCLICK">
            <xsl:text>editItemInIPIPList('</xsl:text>
            <xsl:value-of select="./list[1]/@name" />
            <xsl:text>')</xsl:text>
          </xsl:attribute>
        </input>&newline;
        <br/>&newline;
        <input type="button" value="L&#246;schen">
          <xsl:attribute name="ONCLICK">
            <xsl:text>removeItemFromIPIPList('</xsl:text>
            <xsl:value-of select="./list[1]/@name" />
            <xsl:text>')</xsl:text>
          </xsl:attribute>
        </input>&newline;
      </div>&newline;
    </td>&newline;

    <td colspan="2">
      <div class="content">
        <xsl:apply-templates select="./list"/>
      </div>
    </td>&newline;

</tr>&newline;

</xsl:template>
<!-- ___editIPIPlist___________________________________________________ -->


<!-- ___editMACIPlist__________________________________________________ -->
<xsl:template match="editMACIPlist">
<tr>&newline;

	
  <td>&#160;</td>
  <td><div class="content">MAC-Adresse</div></td>
  <td><div class="content">IP-Adresse</div></td>
</tr>&newline;

<tr>&newline;

    <td>
      <div class="content">
        <input type="button" value="Hinzuf&#252;gen">
          <xsl:attribute name="ONCLICK">
            <xsl:text>addItemToMACList('</xsl:text>
            <xsl:value-of select="./list[1]/@name" />
            <xsl:text>')</xsl:text>
          </xsl:attribute>
        </input>&newline;
      </div>
    </td>&newline;

    <td>
      <div class="content">&newline;
        <input type="text" size="2" maxlength="2" name="mac1"/>&newline;
        <xsl:text>:</xsl:text>&newline;
        <input type="text" size="2" maxlength="2" name="mac2"/>&newline;
        <xsl:text>:</xsl:text>&newline;
        <input type="text" size="2" maxlength="2" name="mac3"/>&newline;
        <xsl:text>:</xsl:text>&newline;
        <input type="text" size="2" maxlength="2" name="mac4"/>&newline;
        <xsl:text>:</xsl:text>&newline;
        <input type="text" size="2" maxlength="2" name="mac5"/>&newline;
        <xsl:text>:</xsl:text>&newline;
        <input type="text" size="2" maxlength="2" name="mac6"/>&newline;
      </div>&newline;
    </td>&newline;

    <td>&newline;
      <div class="content">&newline;
        <input type="text" size="3" maxlength="3" name="ip1" onBlur="validateIP('ip1')" />&newline;
        <xsl:text>.</xsl:text>&newline;
        <input type="text" size="3" maxlength="3" name="ip2" onBlur="validateIP('ip2')" />&newline;
        <xsl:text>.</xsl:text>&newline;
        <input type="text" size="3" maxlength="3" name="ip3" onBlur="validateIP('ip3')" />&newline;
        <xsl:text>.</xsl:text>&newline;
        <input type="text" size="3" maxlength="3" name="ip4" onBlur="validateIP('ip4')" />&newline;
        
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
      </div>
    </td>&newline;

</tr>&newline;

<tr>&newline;

    <td valign="top">
      <div class="content">
        <input type="button" value="Editieren">
          <xsl:attribute name="ONCLICK">
            <xsl:text>editItemInMACList('</xsl:text>
            <xsl:value-of select="./list[1]/@name" />
            <xsl:text>')</xsl:text>
          </xsl:attribute>
        </input>&newline;
        <br/>
        <input type="button" value="L&#246;schen">
          <xsl:attribute name="ONCLICK">
            <xsl:text>removeItemFromMACList('</xsl:text>
            <xsl:value-of select="./list[1]/@name" />
            <xsl:text>')</xsl:text>
          </xsl:attribute>
        </input>&newline;
      </div>
    </td>&newline;

    <td colspan="2">
      <div class="content">
        <xsl:apply-templates select="./list"/>
      </div>
    </td>&newline;

</tr>&newline;

</xsl:template>
<!-- ___editMACIPlist__________________________________________________ -->


</xsl:stylesheet>
