<?xml version="1.0"?>

<!--
scotty-rel - Scotty REVOLUTION Network Management Tool

Authors:
  Thomas Liske <liske@ibh.de>

Copyright Holder:
  2012 (C) IBH IT-Service GmbH [http://www.ibh.de/]

License:
  This program is free software; you can redistribute it and/or modify
  it under the terms of the GNU General Public License as published by
  the Free Software Foundation; either version 2 of the License, or
  (at your option) any later version.

  This program is distributed in the hope that it will be useful,
  but WITHOUT ANY WARRANTY; without even the implied warranty of
  MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
  GNU General Public License for more details.

  You should have received a copy of the GNU General Public License
  along with this package; if not, write to the Free Software
  Foundation, Inc., 51 Franklin St, Fifth Floor, Boston, MA  02110-1301 USA
-->

<xsl:stylesheet version="1.0"
                xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
                xmlns="http://www.w3.org/1999/xhtml">

  <xsl:output method="xml" indent="yes"/>

  <xsl:key name="hosts" match="*[starts-with(@id, 'so_')]" use="substring-before(substring(@id, 4), '_')" />

  <xsl:template match="/">
    <services>
	<xsl:for-each select="//*[generate-id(.)=generate-id(key('hosts', substring-before(substring(@id, 4), '_'))[1])]">
	    <xsl:sort select="substring-before(substring(@id, 4), '_')" />
	    <xsl:variable name="hostname" select="substring-before(substring(@id, 4), '_')"/>
	    <host>
		<xsl:attribute name="name"><xsl:value-of select="$hostname"/></xsl:attribute>
		<xsl:for-each select="//*[substring-before(substring(@id, 4), '_') = $hostname]">
		    <xsl:variable name="service" select="substring-after(substring(@id, 4), '_')"/>
		    <service>
			<xsl:choose>
			    <xsl:when test="contains($service, '_')">
				<xsl:attribute name="name"><xsl:value-of select="substring-before($service, '_')"/></xsl:attribute>
				<xsl:attribute name="name"><xsl:value-of select="substring-after($service, '_')"/></xsl:attribute>
			    </xsl:when>
			    <xsl:otherwise>
				<xsl:attribute name="name"><xsl:value-of select="$service"/></xsl:attribute>
			    </xsl:otherwise>
			</xsl:choose>
		    </service>
		</xsl:for-each>
	    </host>
	</xsl:for-each>
    </services>
  </xsl:template>
</xsl:stylesheet>