#!/usr/bin/python
#-*- coding: utf-8 -*-
#----------------------------------
#Autor:雷锋
#Copyright (C) red star
#License: MIT
#main.py
#----------------------------------

import traceback
import sys
import os
import shutil

import utils
import fileParser
import ios
import re


def getCurrentPath():
	if getattr(sys, 'frozen', None):
		ret = os.path.realpath(os.path.dirname(sys.executable))
	else:
		ret = os.path.realpath(os.path.dirname(__file__))

	return ret

class genIpaUpdate(object):
	"""生成ipa更新配置"""
	reExp = "https://download.bwzq.fytxonline.com/download/ltx/[^/]*"
	def __init__(self, verName, tempDir, srcDir, dstDir):
		super(genIpaUpdate, self).__init__()
		self.verName = verName
		self.tempDir = tempDir
		self.srcDir = srcDir
		self.dstDir = dstDir
		if not os.path.isdir(dstDir):
			os.makedirs(dstDir)

		if os.path.isdir(os.path.join(dstDir, "ipa")):
			shutil.rmtree(os.path.join(dstDir, "ipa"))

	def revisePlist(self, plistPath):
		#正则有点小复杂
		ipaS = "https://download.bwzq.fytxonline.com/download/ltx/ceshi/ipa/default.ipa"
		pngS = "https://download.bwzq.fytxonline.com/download/ltx/ceshi/ipa/Icon-144.png"

		ipaD = "https://download.bwzq.fytxonline.com/download/ltx/%s/ipa/%s.ipa" % (self.verName, self.chlName)
		pngD = "https://download.bwzq.fytxonline.com/download/ltx/%s/ipa/%s.png" % (self.verName, self.chlName)
		
		f = open(plistPath, "r")
		plistInfo = f.read()
		plistInfo = plistInfo.replace(ipaS, ipaD)
		plistInfo = plistInfo.replace(pngS, pngD)
		f.close()
		f = open(plistPath, "w")
		f.write(plistInfo)



	def reviseHtml(self, htmlPath):
		#正则有点小复杂
		plistS = "https://download.bwzq.fytxonline.com/download/ltx/ceshi/ipa/default.plist"
		plistD = "https://download.bwzq.fytxonline.com/download/ltx/%s/ipa/%s.plist" % (self.verName, self.chlName)

		f = open(htmlPath, "r")
		htmlInfo = f.read()
		f.close()
		htmlInfo = htmlInfo.replace(plistS, plistD)
		f = open(htmlPath, "w")
		f.write(htmlInfo)

	def assemble(self, chlName):
		#eg:url=下载服地址(定位到猎天下)/版本号/ipa/aisi-aisi-01.html,Icon-144.png,aisi-aisi-01.plist,aisi-aisi-01.ipa
		self.chlName = chlName
		subDst = os.path.join(self.dstDir, "ipa")
		# #清空目录
		# if os.path.isdir(subDst):
		# 	shutil.rmtree(subDst)
		if not os.path.isdir(subDst):
			os.makedirs(subDst)

		def chlName2Path(dirPath, postfix):
			# print(chlName, postfix)
			return os.path.join(dirPath, ("%s.%s" % (chlName, postfix)) ) 

		#准备好模板
		utils.copyFileInDir(self.tempDir, subDst)
		shutil.copy(chlName2Path(self.srcDir, "ipa"), subDst)
		#抽取png
		ipaPath = chlName2Path(subDst, "ipa")
		pngPath = ios.extractPng(ipaPath)
		os.rename(pngPath , os.path.join(os.path.dirname(ipaPath), "%s.png"% chlName) )

		#修改plist和html
		plistPath = chlName2Path(subDst, "plist")
		htmlPath = chlName2Path(subDst, "html")
		# print(subDst)
		os.rename(os.path.join(subDst, "default.plist"), plistPath)
		os.rename(os.path.join(subDst, "default.html"), htmlPath)

		self.revisePlist(plistPath)
		self.reviseHtml(htmlPath)
		



def main():
	curPath = getCurrentPath()
	verName = 50000
	tempDir = os.path.join(curPath, "template")
	srcDir = os.path.join(curPath, "src")
	dstDir = os.path.join(curPath, str(verName))
	ipaUpObj = genIpaUpdate(verName, tempDir, srcDir, dstDir)
	channelName = (
		"haima",
		"aisi",
		"itools",
		"kuaiyong",
		"tbtui",
		"xy",
		"pp",
		"guopan"
	)

	sucList = []
	for item in channelName:
		ipaPath = os.path.join(srcDir, "%s-%s-01.ipa" % (item, item))
		if os.path.isfile(ipaPath):
			ipaUpObj.assemble( "%s-%s-01" % (item, item) )
			sucList.append(ipaPath)

	#清除下目录
	Payload = os.path.join(curPath, 'Payload')
	if os.path.isdir(Payload):
		shutil.rmtree(Payload)


	print("done, go to outDir to check:\n %s \n " % dstDir)
	print("success ipa:")
	for item in sucList:
		print os.path.basename(item)

if __name__ == '__main__':
	try:
		main()
	except Exception as e:
		traceback.print_exc(e)
		sys.exit(1)
