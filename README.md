# flutter_thesis_final

Flutter frontend project for my thesis

## What to expect?
This project is the frontend for the backend service I have created using the trained sklearn models from my other repo. The accuracy is terrible (around 0.3) with 12 classification labels, but it's a good starting point.

The project works by sending the image to the service via http requests. The image is then processed and given to the model as an input. The resulting prediction and the image's histogram are sent back in json format.


