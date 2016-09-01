#pragma once
#include "cocos2d.h"

class ImgEx : public cocos2d::Image
{
public:
	bool initWithJpgAndAlpha(const std::string& jpgFile, const std::string& alphaFile);
	void dump();

};

