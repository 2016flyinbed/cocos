#include "ImgEx.h"

USING_NS_CC;


bool ImgEx::initWithJpgAndAlpha(const std::string& jpgFile, const std::string& alphaFile)
{
	bool ret = false;
	
	do 
	{
		ret = initWithImageFile(jpgFile);
		CC_BREAK_IF(!ret);
		unsigned char* jData = _data;

		ret = initWithImageFile(alphaFile);
		CC_BREAK_IF(!ret);
		unsigned char* aData = _data;

		_data = (unsigned char *)malloc(_width*_height * 4);
		unsigned char* tempData = _data;
		for (ssize_t i = 0; i < _width*_height; ++i)
		{
			*tempData++ = jData[i*3];
			*tempData++ = jData[i*3 + 1];
			*tempData++ = jData[i*3 + 2];
			*tempData++ = aData[i];
		}
		_renderFormat = Texture2D::PixelFormat::RGBA8888;
		_fileType = Format::PNG;
		CC_SAFE_FREE(jData);
		CC_SAFE_FREE(aData);
		//premultipliedAlpha();
	} while (0);

	return ret;
}

void ImgEx::dump()
{
	log(
		"dataLen = %u, pixelFm = %d, width = %d, height=%d, alphaPremul = %d",
		getDataLen(),
		getRenderFormat(),
		getWidth(),
		getHeight(),
		hasPremultipliedAlpha()
		);
}
