<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform" version="1.0">
  <xsl:output method="text" indent="no"/>
  <xsl:strip-space elements="*"/>

  <xsl:template name="escape">
    <xsl:param name="string"/>
    <xsl:variable name="strFrom">&apos;&quot;</xsl:variable>
    <xsl:value-of select="translate($string, $strFrom, '')"/>
  </xsl:template>

  <!-- Version that produces a text for errorfmt


	<xsl:template match="PVS-Studio_Analysis_Log">
    <xsl:value-of select="File"/>:<xsl:value-of select="Line"/>: (L<xsl:value-of select="Level"/>) <xsl:value-of select="Message"/> -&gt; <xsl:value-of select="ErrorCode"/>
    <xsl:text>
</xsl:text>
  </xsl:template>
  -->
  <!-- Version that produces a qflist (vim dictionary) -->
  <xsl:template match="Solution_Path">[</xsl:template>
  <xsl:template match="PVS-Studio_Analysis_Log">
    <!-- <xsl:if test="position()=1">[</xsl:if>
       - does not work => the match on Solution_Path
       -->
    { 'filename': '<xsl:value-of select="File"/>',
    'lnum': <xsl:value-of select="Line"/>,
    'nr'  : '<xsl:value-of select="translate(ErrorCode, 'V', '')"/>',
    'text': 
    '<xsl:call-template name="escape">
      <xsl:with-param name="string" select="Message"/>
    </xsl:call-template>',
    'type': <xsl:value-of select="Level"/> }
    <xsl:choose>
      <xsl:when test="following-sibling::*">,</xsl:when>
      <xsl:otherwise>]</xsl:otherwise>
    </xsl:choose>
  </xsl:template>

</xsl:stylesheet>
