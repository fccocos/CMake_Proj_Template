#include <iostream>
#include <string>
#include <opencv2/opencv.hpp>

int main(int argc, char const *argv[])
{

    std::string path = "E:/Workspace/cppProj/CMake_Proj_Template/resources/cat_girl.png";
    cv::Mat image = cv::imread(path);
    if(image.empty()){
        std::cerr<< "无法加载图片"<<std::endl;
        return EXIT_FAILURE;
    }

    cv::namedWindow("Display Image", cv::WINDOW_AUTOSIZE);
    cv::imshow("Dispaly Image", image);
    cv::waitKey(0);
    cv::destroyAllWindows();
    return 0;
}

