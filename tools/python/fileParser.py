#!/usr/bin/python
#-*- coding: utf-8 -*-
#----------------------------------
#Autor:雷锋
#Copyright (C) red star
#License: MIT
#parser.py
#----------------------------------
'''
解析文件类
'''

import os

import json
import zipfile
import biplist
import html

#解析json
def parserJson(jsonFile):
	if not os.path.isfile(jsonFile):
		jsonInfo = {}
	else:
		try:
			f = open(jsonFile)
			jsonInfo = json.load(f)
			f.close()
		except:
			jsonInfo = {}

	return jsonInfo

#解析plist
def parserPlist(plistFile):
	if not os.path.isfile(plistFile):
		plistInfo = {}
	else:
		try:
			plistInfo = biplist.readPlist(plistFile)			
		except Exception, e:
			plistInfo = {}

	return plistInfo


#解析zip
def parserZip(zipFile):
	if not os.path.isfile(zipFile):
		zipObj = {}
	else:
		try:
			zipObj = zipfile.ZipFile(zipfile)
		except Exception, e:
			zipObj = {}

	return zipObj
