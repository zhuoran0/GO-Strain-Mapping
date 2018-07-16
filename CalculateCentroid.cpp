#include <iostream>
#include <vector>
#include <cmath>
#include <fstream>
#include <Windows.h>


int CalculateStrainValues(void);
void onMouse(int event, int x, int y, int flags, void* utsc);

bool isClicked;
cv::Point pt;
std::vector<cv::Mat> labelledImgs;

int main()
{
	CalculateStrainValues();

	return 1;
}




int CalculateStrainValues()
{
	// Initialize variables
	int pathIndex = 1;
	int beadID = 1;
	bool IsPoint = false;

	CvFont font;
	cvInitFont(&font, CV_FONT_HERSHEY_SIMPLEX, 1.0, 1.0);

	std::ofstream fout;
	fout.open("D:\\Changhong-Bead\\bead tracking\\Analyzer_Images_Results\\data_.csv");
	fout<<"id,x_0,y_0,match,x_1v,y_1v,match,x_1_5v,y_1_5v,match,x_2v,y_2v,match,x_2_5v,y_2_5v,match,x_3v,y_3v,match,x_3_5v,y_3_5v,match,x_4v,y_4v,match,x_5v,y_5v,match,x_0v_after,y_0v_after"<<std::endl;

	std::string pathPreImage = "D:\\Changhong-Bead\\bead tracking\\Analyzer_Images_Results\\Dark Field\\";

	std::vector<std::vector<cv::Point> > contoursTemplate;

	cv::Mat templateImg = cv::Mat::zeros(1200,1200,CV_8UC1); // Remember to change the image size
	templateImg.setTo(cv::Scalar(0,0,0));

	// Save non-compression image
	std::vector<int> compression_para;
	compression_para.push_back(cv::IMWRITE_PNG_COMPRESSION);
	compression_para.push_back(0);

	// Begin to read images and calculate strains
	for (;;)
	{
		std::string pathname = pathPreImage + std::to_string((long long unsigned)pathIndex) + ".jpg";

		cv::Mat _srcImg = cv::imread(pathname, CV_LOAD_IMAGE_GRAYSCALE);

		if (_srcImg.empty())
		{
			pathIndex = 1;
			beadID++;
			fout<<std::endl;
			continue;
		}


		cv::Mat blurImg, distImg, binImg, distBinImg, colorImg;

		cv::Mat strainImg = cv::Mat::zeros(_srcImg.rows,_srcImg.cols,CV_8UC3);
		strainImg.setTo(cv::Scalar(0,0,0));

		cv::cvtColor(_srcImg, colorImg, CV_GRAY2BGR);

		if ((beadID == 1) && (labelledImgs.size() < pathIndex))
		{
			labelledImgs.push_back(colorImg);
		}

		cv::Mat copyImg; colorImg.copyTo(copyImg);

		// Median Filter
		cv::medianBlur(_srcImg, blurImg, 15);

		//cv::imshow("srcImg", _srcImg);
		//cv::imshow("blurImg", blurImg);

		// Otsu thresholding
		cv::threshold(blurImg, binImg, 0, 255, CV_THRESH_OTSU);

		//cv::imshow("binImg", binImg);

		// Morphology opening
		int erosion_size = 1;  
		cv::Mat element = cv::getStructuringElement(cv::MORPH_ELLIPSE,cv::Size(2 * erosion_size + 1, 2 * erosion_size + 1));
		cv::morphologyEx( binImg, binImg, cv::MORPH_OPEN, element,cv::Point(-1,-1), 3);		//2

		// Find contours
		std::vector<std::vector<cv::Point> > contours;
		cv::findContours(binImg, contours, CV_RETR_EXTERNAL, CV_CHAIN_APPROX_NONE);
		cv::Point2f tempPt;

		std::vector<cv::RotatedRect> allEllipses;

		IsPoint = false;
		
		cv::Mat contourImg = cv::Mat::zeros(_srcImg.rows,_srcImg.cols,CV_8UC1);
		contourImg.setTo(cv::Scalar(0,0,0));
		for (int ii = 0; ii < contours.size(); ++ii)
		{

				cv::Moments mu = cv::moments(contours[ii], true);
				tempPt.x = mu.m10/mu.m00;
				tempPt.y = mu.m01/mu.m00;

				if (contours[ii].size() <= 5)
					continue;

				//fit circles
				cv::RotatedRect rectEllipse = cv::fitEllipse(contours[ii]);
				float ratio = rectEllipse.size.height/rectEllipse.size.width;
				
				if ( 0.5<ratio && ratio<2.0 && rectEllipse.boundingRect().area() <= 2000 )
				{

					cv::circle(labelledImgs[pathIndex-1], tempPt, 1, cv::Scalar(0,255,0), 2);
					//draw contours
					cv::drawContours(labelledImgs[pathIndex-1], contours, ii, cv::Scalar(0,0,255));
					
					cv::drawContours(contourImg, contours, ii, cv::Scalar(255,255,255));
				}
		}

		// Create image window and set mouse clicking events
		// Mouse left click on the same bead across images
		cv::namedWindow("labelledImg");
		cv::setMouseCallback("labelledImg", onMouse, 0);
		cv::imshow("labelledImg",labelledImgs[pathIndex-1]);
		//cv::imshow("templateImg", templateImg);

		isClicked = false;

		int key = cv::waitKey();
		if (key == 27)	//Press "ESC" to exit
		{
			break;
		}


		for (int ii = 0; ii < contours.size(); ++ii)
		{
			cv::Moments mu = cv::moments(contours[ii], true);
			tempPt.x = mu.m10/mu.m00;
			tempPt.y = mu.m01/mu.m00;

			if (abs(pt.x-tempPt.x) < 10 && abs(pt.y-tempPt.y) < 10 && isClicked)
			{
				IsPoint = true;

				cv::circle(copyImg, tempPt, 3, cv::Scalar(0,255,0), 5);
				cv::circle(copyImg, pt, 3, cv::Scalar(0,0,255), 5);

				cv::putText(labelledImgs[pathIndex-1], std::to_string((long long unsigned)beadID),cv::Point(tempPt.x+5, tempPt.y+5) ,CV_FONT_HERSHEY_SIMPLEX, 0.7, cv::Scalar(0,255,0));
				cv::Rect scaleBarRect = cv::boundingRect(contours[ii]);

				// Calculate match_score by template matching
				if (pathIndex == 1)
				{
					fout<<beadID<<","<<tempPt.x<<","<<tempPt.y<<",";
					
					cv::Rect contourBound = cv::boundingRect(contours[ii]);
					int extendWidth = 0;	//0
					cv::Rect recBound(contourBound.tl().x-extendWidth, contourBound.tl().y-extendWidth, contourBound.size().width+extendWidth*2, contourBound.size().height+extendWidth*2);
					templateImg = cv::Mat::zeros(recBound.size(), CV_8UC1);
					contourImg(recBound).copyTo(templateImg);
				}
				else
				{
					double matchScore = -100;
					
					cv::Mat testImg = cv::Mat::zeros(templateImg.rows+10, templateImg.cols+10, CV_8UC1);
					int tl_x = tempPt.x-testImg.cols/2 < 0 ? 0 : tempPt.x-testImg.cols/2;
					tl_x = tempPt.x-testImg.cols/2+testImg.cols > 1200 ? 1200-testImg.cols : tempPt.x-testImg.cols/2;
					int tl_y = tempPt.y-testImg.rows/2 < 0 ? 0 : tempPt.y-testImg.rows/2;
					tl_y = tempPt.y-testImg.rows/2+testImg.rows > 1200 ? 1200-testImg.rows : tempPt.y-testImg.rows/2;
					
					cv::Rect roiRect(tl_x, tl_y, testImg.cols, testImg.rows);


					contourImg(roiRect).copyTo(testImg);
					//cv::imshow("templateImg", templateImg);

					cv::Mat matchImg;	cv::Point matchPt;
					cv::matchTemplate(testImg, templateImg, matchImg, 5);
					cv::minMaxLoc(matchImg, 0, &matchScore, NULL, &matchPt);

					std::cout<<"match score: "<<matchScore<<std::endl;

					fout<<matchScore<<","<<tempPt.x<<","<<tempPt.y<<",";

				}	

			}
		}

		if (IsPoint == false)
		{
			fout<<","<<","<<",";
			std::cout<<"Please choose a different point"<<std::endl;
			continue;
		}

		cv::imshow("Reference Image", copyImg);

		pathIndex++;
		
	}

	for (int ii = 0; ii < labelledImgs.size(); ++ii)
	{
		std::string savepathname = pathPreImage + std::to_string((long long unsigned)(ii+1)) + "-labelled.png";
		cv::imwrite(savepathname,labelledImgs[ii], compression_para);
	}

	fout<<std::flush;
	fout.close();

	return 1;
}


//Mouse click callBackFunction
void onMouse(int event, int x, int y, int flags, void* utsc)
{
	if (event == CV_EVENT_LBUTTONDOWN)
	{
		pt.x = x;
		pt.y = y;
		isClicked = true;
	}

}