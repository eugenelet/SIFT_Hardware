#include "opencv2/opencv.hpp"
#include <unistd.h>
#include <iostream>
#include <stdio.h>
#include <stdlib.h>
#include <string>
#include <fstream>

#include "opencv2/core/core.hpp"
#include "opencv2/features2d/features2d.hpp"
#include "opencv2/highgui/highgui.hpp"
#include "opencv2/calib3d/calib3d.hpp"
#include "opencv2/nonfree/nonfree.hpp"
#include <opencv2/imgproc.hpp>

#define CLUSTERS 	4
#define	ELEMENTS	4096

using namespace std;
using namespace cv;


struct element
{
	int x;
	int	y;	
	int count;
	element(int _x = 0, int _y = 0, int _count = 0):
		x(_x), y(_y), count(_count){}
};


int read_line_as_token(const string &line, vector<string> &tokens)
{
    tokens.clear();
    string token;
    for(int g=0;g<line.size();g++)
    {
        if(line[g]==' ' || line[g] == '\n' || line[g] == '\r' )
        {
            if(token.size()!=0 &&token[0]!=' ')
            {
                tokens.push_back(token);
                token.clear();
            }   
        }
        else
        {
            token.push_back(line[g]);
        }
    }
    if(token.size()!=0 && token[0]!=' ')
    tokens.push_back(token);
    return 0;
}


void parserInput(element* currentElement, element* totalElement, const string &input_file){
	ifstream in(input_file.c_str(), ios::in);
	string line;
	vector<string> tokens;
	for(int i = 0; i < CLUSTERS; i++){
		getline(in, line);
		read_line_as_token(line, tokens);
		currentElement[i].x = atoi(tokens[0].c_str());
		currentElement[i].y = atoi(tokens[1].c_str());
	}
	for(int i = 0; i < ELEMENTS && !in.eof(); i++){
		getline(in, line);
		read_line_as_token(line, tokens);
		totalElement[i].x = atoi(tokens[0].c_str());
		totalElement[i].y = atoi(tokens[1].c_str());
	}

}

bool check(element* preElement, element* currentElement){
	return 	(preElement[0].x!=currentElement[0].x || preElement[0].y!=currentElement[0].y ||
			 preElement[1].x!=currentElement[1].x || preElement[1].y!=currentElement[1].y ||
			 preElement[2].x!=currentElement[2].x || preElement[2].y!=currentElement[2].y ||
			 preElement[3].x!=currentElement[3].x || preElement[3].y!=currentElement[3].y);
}

void GroupAndAccumulate(element* totalElement, element* currentElement, element* accuElement, int* data_num){
	for(int i = 0; i < ELEMENTS; i++){
		int min_idx = 0;
		int min_distance = 0;
		for(int j = 0; j < CLUSTERS; j++){
			int distance = abs(currentElement[j].x - totalElement[i].x);
			distance += abs(currentElement[j].y - totalElement[i].y);
			if(j==0 || distance<min_distance){
				min_idx = j;
				min_distance = distance;
			}
		}
		data_num[min_idx]++;
		accuElement[min_idx].x += totalElement[i].x;
		accuElement[min_idx].y += totalElement[i].y;
	}
}

void UpdateClusterPosition(element* preElement, element* currentElement, element* accuElement, int* data_num){
	for(int i = 0; i < CLUSTERS; i++){
		preElement[i].x = currentElement[i].x;
		preElement[i].y = currentElement[i].y;
		if(data_num[i] > 0){
			currentElement[i].x = accuElement[i].x / data_num[i];
			currentElement[i].y = accuElement[i].y / data_num[i];
		}
	}
}



int main(int argc, char** argv){
	string input_file = argv[1];

	element* preElement = new element[CLUSTERS];
	element* currentElement = new element[CLUSTERS];
	element* accuElement = new element[CLUSTERS];
	element* totalElement = new element[ELEMENTS];
	int* data_num = new int[CLUSTERS];
	parserInput(currentElement, totalElement, input_file);
	Mat image = Mat::zeros( 256, 256, CV_8UC3 );

	for(int i = 0; i < CLUSTERS; i++){
		data_num[i] = 0;
	}

	for(int i = 0; i < ELEMENTS/4; i++){
		circle(image, Point(totalElement[i].x,totalElement[i].y), 1, Scalar(60, 10, 0));
		//cout << Point(totalElement[i].x,totalElement[i].y).x << " " << Point(totalElement[i].x,totalElement[i].y).y << endl;
	}
	for(int i = ELEMENTS/4; i < (ELEMENTS*2)/4; i++){
		circle(image, Point(totalElement[i].x,totalElement[i].y), 1, Scalar(10, 60, 5));
		//cout << Point(totalElement[i].x,totalElement[i].y).x << " " << Point(totalElement[i].x,totalElement[i].y).y << endl;
	}
	for(int i = ELEMENTS/2; i < (ELEMENTS*3)/4; i++){
		circle(image, Point(totalElement[i].x,totalElement[i].y), 1, Scalar(10, 0, 60));
		//cout << Point(totalElement[i].x,totalElement[i].y).x << " " << Point(totalElement[i].x,totalElement[i].y).y << endl;
	}
	for(int i = (ELEMENTS*3)/4; i < ELEMENTS; i++){
		circle(image, Point(totalElement[i].x,totalElement[i].y), 1, Scalar(30, 0, 60));
		//cout << Point(totalElement[i].x,totalElement[i].y).x << " " << Point(totalElement[i].x,totalElement[i].y).y << endl;
	}


	for(int i = 0; i < CLUSTERS; i++){
		circle(image, Point(currentElement[i].x,currentElement[i].y), 2, Scalar(0, 255, 255));
	}

	while( check(preElement, currentElement) ){
		GroupAndAccumulate(totalElement, currentElement, accuElement, data_num);
		UpdateClusterPosition(preElement, currentElement, accuElement, data_num);
		for(int i = 0; i < CLUSTERS; i++){
			circle(image, Point(currentElement[i].x,currentElement[i].y), 1, Scalar(255, 255, 255));
			accuElement[i].x = 0;
			accuElement[i].y = 0;
			data_num[i] = 0;
		}
	}
	for(int i = 0; i < CLUSTERS; i++){
		circle(image, Point(currentElement[i].x,currentElement[i].y), 3, Scalar(255, 255, 0));
	}
	imshow("Image",image);
	waitKey( 0 );
	return(0);
}