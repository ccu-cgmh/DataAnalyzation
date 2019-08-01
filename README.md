# DataAnalyzation
比較光學系統、sensor積分、Blender模型的數據。
## Folder
- **\OpticalInput:** 存放光學系統的原始檔案。  
- **\OpticalOutnput:** 存放光學系統提取特定光點位置的檔案。
- **\0621Sensor:** 時間對齊過後的sensor數據。
- **\0621-location-Mark**: Blender模型推算出的各部位關節位置數據。
- **\Quaternions**: Matlab四元數運算的函式。
## Code
- **ReadOpticalCsv.py:** 讀取光學系統原始檔案，提取特定光點的座標位置，輸出到\OpticalOutnput。
- **SensorData.m** 積分Sensor數據，算得位移並與光學系統、Blender模型比較。
