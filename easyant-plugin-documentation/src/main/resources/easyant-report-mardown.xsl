<?xml version="1.0" encoding="ISO-8859-1"?>
	<!--
		Licensed to the Apache Software Foundation (ASF) under one or more
		contributor license agreements. See the NOTICE file distributed with
		this work for additional information regarding copyright ownership.
		The ASF licenses this file to You under the Apache License, Version
		2.0 (the "License"); you may not use this file except in compliance
		with the License. You may obtain a copy of the License at

		http://www.apache.org/licenses/LICENSE-2.0 Unless required by
		applicable law or agreed to in writing, software distributed under the
		License is distributed on an "AS IS" BASIS, WITHOUT WARRANTIES OR
		CONDITIONS OF ANY KIND, either express or implied. See the License for
		the specific language governing permissions and limitations under the
		License.
	-->
<xsl:stylesheet version="1.0"
	xmlns:xsl="http://www.w3.org/1999/XSL/Transform" xmlns:ea="antlib:org.apache.easyant">

	<xsl:param name="extension" select="'xml'" />
	<xsl:output method="text" />
	<xsl:strip-space elements="*" />

	<xsl:variable name="myorg" select="/easyant-report/info/@organisation" />
	<xsl:variable name="mymod" select="/easyant-report/info/@module" />
	<xsl:variable name="myconf" select="/easyant-report/info/@conf" />

	<xsl:variable name="modules" select="/easyant-report/dependencies/module" />
	<xsl:variable name="conflicts" select="$modules[count(revision) > 1]" />

	<xsl:variable name="revisions" select="$modules/revision" />
	<xsl:variable name="evicteds" select="$revisions[@evicted]" />
	<xsl:variable name="downloadeds" select="$revisions[@downloaded='true']" />
	<xsl:variable name="searcheds" select="$revisions[@searched='true']" />
	<xsl:variable name="errors" select="$revisions[@error]" />

	<xsl:variable name="artifacts" select="$revisions/artifacts/artifact" />
	<xsl:variable name="cacheartifacts" select="$artifacts[@status='no']" />
	<xsl:variable name="dlartifacts" select="$artifacts[@status='successful']" />
	<xsl:variable name="faileds" select="$artifacts[@status='failed']" />
	<xsl:variable name="artifactsok" select="$artifacts[@status!='failed']" />

	<xsl:variable name="configurations" select="/easyant-report/configurations" />
	<xsl:variable name="easyant" select="/easyant-report/easyant" />
	<xsl:variable name="targets" select="$easyant/targets" />
	<xsl:variable name="extensionPoints" select="$easyant/extension-points" />
	<xsl:variable name="imports" select="$easyant/imports" />

	<xsl:variable name="newline">
		<xsl:text>
</xsl:text>
	</xsl:variable>


	<xsl:template name="calling">
		<xsl:param name="org" />
		<xsl:param name="mod" />
		<xsl:param name="rev" />
		<xsl:if
			test="count($modules/revision/caller[(@organisation=$org and @name=$mod) and @callerrev=$rev]) = 0">
			<xsl:text>No dependency</xsl:text>
		</xsl:if>
		<xsl:if
			test="count($modules/revision/caller[(@organisation=$org and @name=$mod) and @callerrev=$rev]) > 0">
			<xsl:text>|Organisation|Module|Revision|</xsl:text>
			<xsl:value-of select="$newline" />
			<xsl:for-each
				select="$modules/revision/caller[(@organisation=$org and @name=$mod) and @callerrev=$rev]">
				<xsl:call-template name="called">
					<xsl:with-param name="callstack"
						select="concat($org, string('/'), $mod)" />
					<xsl:with-param name="indent" select="string('')" />
					<xsl:with-param name="revision" select=".." />
				</xsl:call-template>
			</xsl:for-each>
		</xsl:if>
		<xsl:value-of select="$newline" />
	</xsl:template>

	<xsl:template name="called">
		<xsl:param name="callstack" />
		<xsl:param name="indent" />
		<xsl:param name="revision" />

		<xsl:param name="organisation" select="$revision/../@organisation" />
		<xsl:param name="module" select="$revision/../@name" />
		<xsl:param name="rev" select="$revision/@name" />
		<xsl:param name="resolver" select="$revision/@resolver" />
		<xsl:param name="isdefault" select="$revision/@default" />
		<xsl:param name="status" select="$revision/@status" />

		<xsl:text>|</xsl:text>
		<xsl:value-of select="$organisation" />
		<xsl:text>|</xsl:text>
		<xsl:value-of select="$module" />
		<xsl:text>|</xsl:text>
		<xsl:value-of select="$rev" />
		<xsl:text>|</xsl:text>
		<xsl:value-of select="$newline" />
	</xsl:template>

	<xsl:template match="configurations">
		<xsl:text>## Ivy Configurations</xsl:text>
		<xsl:value-of select="$newline" />
		<xsl:value-of select="$newline" />

		<xsl:text>|name|description|extends|visibility|deprecated|</xsl:text>
		<xsl:value-of select="$newline" />
		<xsl:text>|----|-----------|-------|----------|----------|</xsl:text>
		<xsl:value-of select="$newline" />
		<xsl:for-each select="configuration">
			<xsl:text>|</xsl:text>
			<xsl:value-of select="@name" />
			<xsl:text>|</xsl:text>
			<xsl:value-of select="@description" />
			<xsl:text>|</xsl:text>
			<xsl:value-of select="@extends" />
			<xsl:text>|</xsl:text>
			<xsl:value-of select="@visibility" />
			<xsl:text>|</xsl:text>
			<xsl:if test="@deprecated != null">
				<xsl:value-of select="@deprecated" />
			</xsl:if>
			<xsl:text>|</xsl:text>
			<xsl:value-of select="$newline" />
		</xsl:for-each>
		<xsl:value-of select="$newline" />
	</xsl:template>

	<xsl:template match="/easyant-report">
		<xsl:text># Documentation :: </xsl:text>
		<xsl:value-of select="info/@module" />
		<xsl:text> by </xsl:text>
		<xsl:value-of select="info/@organisation" />
		<xsl:value-of select="$newline" />
		<xsl:value-of select="$newline" />

		<xsl:text># Description</xsl:text>
		<xsl:value-of select="$newline" />
		<xsl:value-of select="description" />
		<xsl:value-of select="$newline" />

		<xsl:text># Example</xsl:text>
		<xsl:value-of select="$newline" />
		<xsl:value-of select="$newline" />

		<!-- example with all arguments -->
		<xsl:text>```xml</xsl:text>
		<xsl:value-of select="$newline" />
		<xsl:text>&lt;ea:plugin organisation="</xsl:text>
		<xsl:value-of select="info/@organisation" />
		<xsl:text>" module="</xsl:text>
		<xsl:value-of select="info/@module" />
		<xsl:text>" revision="</xsl:text>
		<xsl:value-of select="info/@revision" />
		<xsl:text>"/&gt;</xsl:text>
		<xsl:value-of select="$newline" />
		<xsl:text>```</xsl:text>
		<xsl:value-of select="$newline" />

		<xsl:text>Organisation attribute is optional. If not specified default one will be used.</xsl:text>
		<xsl:value-of select="$newline" />
		<xsl:value-of select="$newline" />

		<!-- Example without organisation attribute as it is optional -->
		<xsl:text>```xml</xsl:text>
		<xsl:value-of select="$newline" />
		<xsl:text>&lt;ea:plugin module="</xsl:text>
		<xsl:value-of select="info/@module" />
		<xsl:text>" revision="</xsl:text>
		<xsl:value-of select="info/@revision" />
		<xsl:text>"/&gt;</xsl:text>
		<xsl:value-of select="$newline" />
		<xsl:text>```</xsl:text>
		<xsl:value-of select="$newline" />
		<xsl:value-of select="$newline" />

		<xsl:apply-templates select="easyant" />
		<xsl:apply-templates select="configurations" />

		<xsl:text>## Dependencies Overview</xsl:text>
		<xsl:value-of select="$newline" />
		<xsl:value-of select="$newline" />
		
		<xsl:call-template name="calling">
			<xsl:with-param name="org" select="info/@organisation" />
			<xsl:with-param name="mod" select="info/@module" />
			<xsl:with-param name="rev" select="info/@revision" />
		</xsl:call-template>

	</xsl:template>

	<xsl:template match="easyant">
		<xsl:if test="count(targets/target) > 0">
			<xsl:text>## Available targets</xsl:text>
			<xsl:value-of select="$newline" />
			<xsl:value-of select="$newline" />
			
			<xsl:text>|target name|description|extension point|depends|</xsl:text>
			<xsl:value-of select="$newline" />
			<xsl:text>|-----------|-----------|---------------|-------|</xsl:text>
			<xsl:value-of select="$newline" />
			<xsl:apply-templates select="targets/target" />
			<xsl:value-of select="$newline" />
		</xsl:if>

		<xsl:if test="count(extension-points/extension-point) > 0">
			<xsl:text>## Available extension points</xsl:text>
			<xsl:value-of select="$newline" />
			<xsl:value-of select="$newline" />
			
			<xsl:text>|target name|description|depends|</xsl:text>
			<xsl:value-of select="$newline" />
			<xsl:text>|-----------|-----------|-------|</xsl:text>
			<xsl:value-of select="$newline" />
			<xsl:apply-templates select="extension-points/extension-point" />
			<xsl:value-of select="$newline" />
		</xsl:if>

		<xsl:if test="count(imports/import) > 0">
			<xsl:text>## Imported module</xsl:text>
			<xsl:value-of select="$newline" />
			<xsl:value-of select="$newline" />
			
			<xsl:text>|organisation|module|revision|Import type|prefix|</xsl:text>
			<xsl:value-of select="$newline" />
			<xsl:text>|------------|------|--------|-----------|------|</xsl:text>
			<xsl:value-of select="$newline" />
			<xsl:apply-templates select="imports/import" />
			<xsl:value-of select="$newline" />
		</xsl:if>

		<xsl:if test="count(properties/property) > 0">
			<xsl:text>## Module parameters</xsl:text>
			<xsl:value-of select="$newline" />
			<xsl:value-of select="$newline" />
			
			<xsl:text>### Properties</xsl:text>
			<xsl:value-of select="$newline" />
			<xsl:value-of select="$newline" />
			
			<xsl:text>|property|description|required|default value|</xsl:text>
			<xsl:value-of select="$newline" />
			<xsl:text>|--------|-----------|--------|-------------|</xsl:text>
			<xsl:value-of select="$newline" />
			<xsl:for-each select="properties/property">
				<xsl:text>|</xsl:text>
				<xsl:value-of select="@name" />
				<xsl:text>|</xsl:text>
				<xsl:value-of select="@description" />
				<xsl:text>|</xsl:text>
				<xsl:value-of select="@required" />
				<xsl:text>|</xsl:text>
				<xsl:value-of select="@default" />
				<xsl:text>|</xsl:text>
				<xsl:value-of select="$newline" />
			</xsl:for-each>
			<xsl:value-of select="$newline" />
		</xsl:if>

		<xsl:if test="count(parameters/parameter) > 0">
			<xsl:text>### Paths</xsl:text>
			<xsl:value-of select="$newline" />
			<xsl:value-of select="$newline" />
			
			<xsl:text>|path|description|required|</xsl:text>
			<xsl:value-of select="$newline" />
			<xsl:text>|----|-----------|--------|</xsl:text>
			<xsl:value-of select="$newline" />
			<xsl:for-each select="parameters/path">
				<xsl:text>|</xsl:text>
				<xsl:value-of select="@name" />
				<xsl:text>|</xsl:text>
				<xsl:value-of select="@description" />
				<xsl:text>|</xsl:text>
				<xsl:value-of select="@required" />
				<xsl:text>|</xsl:text>
				<xsl:value-of select="$newline" />
			</xsl:for-each>
			<xsl:value-of select="$newline" />
		</xsl:if>

	</xsl:template>

	<xsl:template match="target">
		<xsl:text>|</xsl:text>
		<xsl:value-of select="@name" />
		<xsl:text>|</xsl:text>
		<xsl:value-of select="@description" />
		<xsl:text>|</xsl:text>
		<xsl:value-of select="@extensionOf" />
		<xsl:text>|</xsl:text>
		<xsl:value-of select="@depends" />
		<xsl:text>|</xsl:text>
		<xsl:value-of select="$newline" />
	</xsl:template>

	<xsl:template match="extension-points/extension-point">
		<xsl:text>|</xsl:text>
		<xsl:value-of select="@name" />
		<xsl:text>|</xsl:text>
		<xsl:value-of select="@description" />
		<xsl:text>|</xsl:text>
		<xsl:value-of select="@depends" />
		<xsl:text>|</xsl:text>
		<xsl:value-of select="$newline" />
	</xsl:template>

	<xsl:template match="import">
		<xsl:text>|</xsl:text>
		<xsl:value-of select="@organisation" />
		<xsl:text>|</xsl:text>
		<xsl:value-of select="@name" />
		<xsl:text>|</xsl:text>
		<xsl:value-of select="@revision" />
		<xsl:text>|</xsl:text>
		<xsl:value-of select="@type" />
		<xsl:text>|</xsl:text>
		<xsl:value-of select="@as" />
		<xsl:text>|</xsl:text>
		<xsl:value-of select="$newline" />
	</xsl:template>
</xsl:stylesheet>