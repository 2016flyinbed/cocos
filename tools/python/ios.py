#!/usr/bin/python
#-*- coding: utf-8 -*-
#----------------------------------
#Autor:雷锋
#Copyright (C) red star
#License: MIT
#ios.py
#----------------------------------
'''
处理ios相关的工具函数
http://www.cppblog.com/Khan/archive/2015/01/04/209386.html
'''
import zipfile
import biplist
import re
import os
import shutil
import fileParser

import utils

'''
解析html
'''
from sgmllib import SGMLParser

import BeautifulSoup

class ParserHtml(SGMLParser):
	# def __init__(self):
	# 	# super(ParserHtml, self).__init__()
	# 	SGMLParser.__init__(self)
	# 	self.list = []
		
	def reset(self):
		self.list = []
		self.isScript = False
		self.isA = False
		SGMLParser.reset(self)

	def start_script(self, attrs):
		print(attrs)
		self.isScript = True

	def end_script(self):
		self.isScript = False

	def start_a(self, attrs):
		print("a:", attrs)
		self.isA = True

	def end_a(self):
		self.isA = False

	def handle_data(self, data):
		if self.isScript:
			print(data)
			self.list.append(data)

		if self.isA:
			print(data)

def reviseHtml(htmlPath):
	pass

def revisePlist(plistPath):
	print(plistPath)
	plistDict = fileParser.parserPlist(plistPath)
	# print(plistDict)
	assetsList = plistDict['items'][0]['assets']



	for item in assetsList:
		print item


def extractPng(ipaPath):
	zipObj = zipfile.ZipFile(ipaPath)
	pngPath = findInPath(zipObj, 'Payload/[^/]*.app/Icon-144.png')
	zipObj.extract(pngPath)
	ipaDir = os.path.dirname(ipaPath)

	shutil.copy(pngPath, ipaDir)
	return os.path.join(ipaDir, os.path.basename(pngPath))

def findInPath(zipFileObj, rePattern):
	pattern = re.compile(r'%s' % rePattern)
	for path in zipFileObj.namelist():
		m = pattern.match(path)
		if m is not None:
			return m.group()

def analyzeIpa(ipaPath):
	zipObj = zipfile.ZipFile(ipaPath)
	#解析plist
	plistPath = findInPath(zipObj, 'Payload/[^/]*.app/Info.plist')
	plistDict = biplist.readPlistFromString(zipObj.read(plistPath))

	#png
	pngPath = findInPath(zipObj, 'Payload/[^/]*.app/Icon-144.png')
	zipObj.extract(pngPath)
	# print(pngPath, os.path.basename(pngPath))
	# shutil.move(os.path.join(curPath, pngPath), curPath )