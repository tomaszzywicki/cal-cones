import torch
import torchvision
print(torch.__version__, torch.version.cuda)
print(torchvision.__version__)
print("CUDA available:", torch.cuda.is_available())


