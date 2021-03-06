<?xml version="1.0" encoding="UTF-8"?>
<!--
   Purpose:
     Transform DocBook document into single XHTML file

   Parameters:
     Too many to list here, see:
     http://docbook.sourceforge.net/release/xsl/current/doc/html/index.html

   Input:
     DocBook 4/5 document

   Output:
     Single XHTML file

   See Also:
     * http://doccookbook.sf.net/html/en/dbc.common.dbcustomize.html
     * http://sagehill.net/docbookxsl/CustomMethods.html#WriteCustomization

   Authors:    Thomas Schraitle <toms@opensuse.org>,
               Stefan Knorr <sknorr@suse.de>,
               Rick Salevsky <rsalevsky@suse.de>
   Copyright:  2012, 2013, 2014, Thomas Schraitle, Stefan Knorr, Rick Salevsky

-->

<xsl:stylesheet version="1.0"
    xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
    xmlns:exsl="http://exslt.org/common"
    xmlns:date="http://exslt.org/dates-and-times"
    xmlns="http://www.w3.org/1999/xhtml"
    exclude-result-prefixes="exsl date">

  <!-- FIXME: Better use a full URL for catalog-based resolution here? The
       caveat of doing that would of course be possible dependency issues,
       since we generally want matching stylesheets not any and all that are
       installed on the system. -->
  <xsl:import href="../../suse2013/xhtml/docbook.xsl"/>

  <xsl:include href="../version.xsl"/>

  <xsl:template name="user.footer.content">
    <div id="_footer">
      <p>©
        <xsl:if test="function-available('date:year')">
          <xsl:value-of select="date:year()"/>
          <xsl:text> </xsl:text>
        </xsl:if>
        SUSE</p>
    </div>
  </xsl:template>

  <xsl:param name="allow.email.sharelink" select="0"/>
  <xsl:param name="extra.css" select="'static/css/brand.css'"/>

</xsl:stylesheet>
