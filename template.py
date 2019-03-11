import cv2

def lambda_handler(event, context):
	print("OpenCV installed version: {}".format(cv2.__version__))
	return "It works fam!"

if __name__ == "__main__":
	lambda_handler(42, 42)
