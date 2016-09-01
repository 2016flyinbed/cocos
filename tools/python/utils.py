#!/usr/bin/python
#-*- coding: utf-8 -*-
#----------------------------------
#Autor:雷锋
#Copyright (C) red star
#License: MIT
#utils.py
#----------------------------------
import os
import sys
import subprocess
import shutil

'''
工具函数
'''
def checkDir(dirPath):
	if not os.path.isdir(dirPath):
		os.makedirs(dirPath)

	return dirPath

#判断平台
def osIsWin32():
	return sys.platform == 'win32'

def osIsMac():
	return sys.platform == 'darwin'

'''
日志管理类
'''
class Logging:
	# 控制台变色 
	RED = '\033[31m'
	GREEN = '\033[32m'
	YELLOW = '\033[33m'
	MAGENTA = '\033[35m'
	RESET = '\033[0m'
	
	@staticmethod
	def _print(s, color=None):
		if color and sys.stdout.isatty() and not osIsWin32():
			print(color + s + Logging.RESET)
		else:
			print(s)

	@staticmethod
	def debug(s):
		Logging._print(s, Logging.MAGENTA)

	@staticmethod
	def info(s):
		Logging._print(s, Logging.GREEN)

	@staticmethod
	def warning(s):
		Logging._print(s, Logging.YELLOW)

	@staticmethod
	def error(s):
		Logging._print(s, Logging.RED)


'''
cmd命令运行器
'''
class CmdRunner(object):
	@staticmethod
	def runCmd(cmd, verbose=True):
		if verbose:
			Logging.debug("running:'%s'\n" % ''.join(cmd))
		else:
			pass

		ret = subprocess.call(cmd, shell=True)
		if ret != 0:
			msg = "Error running command, return code: %s" % str(ret)
			Logging.debug(msg)
			raise PluginError(msg)

'''
插件错误处理
'''
class PluginError(Exception):
	pass


'''
拷贝文件
'''
def copyFileInDir(src, dst):	
	for item in os.listdir(src):
		path = os.path.join(src, item)
		if os.path.isfile(path):
			shutil.copy(path, dst)
		if os.path.isdir(path):
			newDst = os.path.join(dst, item)
			if not os.path.isdir(newDst):
				os.makedirs(newDst)
			copyFileInDir(path, newDst)

def copyFileWithConfig(config, srcRoot, dstRoot):
	srcDir = config["from"]
	dstDir = config["to"]

	srcDir = os.path.join(srcRoot, srcDir)
	dstDir = os.path.join(dstRoot, dstDir)

	includeRules = None
	if "include" in config:
		includeRules = config["include"]
		includeRules = _convertRules(includeRules)

	excludeRules = None
	if "exclude" in config:
		excludeRules = config["exclude"]
		excludeRules = _convertRules(excludeRules)

	copyFileWithRules(srcDir, srcDir, dstDir, includeRules, excludeRules)


def copyFileWithRules(srcRoot, src, dst, include=None, exclude=None):
	if os.path.isfile(src):
		if not os.path.exists(dst):
			os.makedirs(dst)
		#涉及到平台差异(暂不处理)
		copySrc = src
		copyDst = dst 
		shutil.copy(copySrc, copyDst)
		return

	if (include is None) and (exclude is None):
		if not os.path.exists(dst):
			os.makedirs(dst)
		copyFileInDir(src, dst)
	elif(include is not None):
		for item in os.listdir(src):
			absPath = os.path.join(src, item)
			relPath = os.path.relpath(absPath, srcRoot)

			if os.path.isdir(absPath):
				subDst = os.path.join(dst, item)
				copyFileWithRules(srcRoot, absPath, subDst, include=include)
			elif os.path.isfile(absPath):
				if _inRules(relPath, include):
					if not os.path.exists(dst):
						os.makedirs(dst)
				shutil.copy(absPath, dst)
	elif(exclude is not None):
		for item in os.listdir(src):
			absPath = os.path.join(src, item)
			relPath = os.path.relpath(absPath, srcRoot)
			if os.path.isdir(absPath):
				subDst = os.path.join(dst, item)
				copyFileWithRules(srcRoot, absPath, subDst, exclude=exclude)
			elif os.path.isfile(

				):
				if not _inRules(relpath, exclude):
					if not os.path.exists(dst):
						os.makedirs(dst)

				shutil.copy(absPath, dst)

def _convertRules(rules):
	retRules = []
	for rule in rules:
		ret = rule.replace(".", "\\.")
		ret = rule.replace("*", ".*")
		ret = "%s" % ret
		retRules.append(ret)

	return retRules

def _inRules(relPath, rules):
	import re
	ret = False
	pathStr = relpath.replace("\\", "/")
	for rule in rules:
		if re.match(rule, pathStr):
			ret = True

	return ret

'''
删除文件
'''
#删除一级目录下的所有文件 
def removeFileInDir(srcDir):
	for item in os.listdir(srcDir):
		path = os.path.join(srcDir, item)
		if os.path.isfile(path):
			os.remove(path)

		if os.path.isdir(path):
			removeFileInDir(path)

