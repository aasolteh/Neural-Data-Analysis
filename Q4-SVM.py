import numpy as np
from sklearn.model_selection import train_test_split
import scipy.io
from sklearn import svm
from sklearn.metrics import confusion_matrix
import matplotlib.pyplot as plt
import time
import seaborn as sns
from sklearn.metrics import accuracy_score
from sklearn.metrics import recall_score


allSessions = scipy.io.loadmat('windowedData.mat')['windowedData']
condMap = scipy.io.loadmat('cond.mat')['Cond']
condMap.shape = [condMap.shape[0], ]
condMap[condMap <= 8] = 1
condMap[condMap > 8] = 2

recall = np.zeros((200, len(allSessions[0,0]), 2))

for j in range(200):
  print(j)
  for i in range(len(allSessions[0,0])):
    X_train, X_test, y_train, y_test = train_test_split(allSessions[:,:,i], condMap, test_size=0.2, random_state=j)
    rbf_svc = svm.SVC(kernel='rbf')
    rbf_svc = rbf_svc.fit(X_train, y_train)
    y_pred = rbf_svc.predict(X_test)
    recall[j, i, :] = recall_score(y_test, y_pred, average = None)
  if j % 10 == 0:
    with open('recall.npy', 'wb') as f:
      np.save(f, recall)

with open('recall.npy', 'wb') as f:
      np.save(f, recall)