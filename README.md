# GTP-MOTORSPORT-LAP-TIME-SIMULATOR
A forward-backward pass lap time simulator for Daytona and Le Mans, built in MATLAB, testing GTP IMSA and Le Mans configurations..
# IMSA GTP Lap Time & Telemetry Simulator

## 📌 Overview
This project is a physics-based, point-mass vehicle dynamics simulator built in MATLAB. It uses a forward-backward pass algorithm to generate realistic telemetry, braking zones, and lap times for IMSA GTP and WEC Hypercars. 

## 🏎️ Track Layouts Modeled
* **Daytona International Speedway:** 5.73 km road course featuring accurate 31-degree banking physics.
* **Circuit de la Sarthe (Le Mans):** 13.62 km layout featuring the Mulsanne chicanes and Porsche curves.

## ⚙️ Physics & Aerodynamics
The simulator accounts for:
* Engine power curves and gearing.
* Aerodynamic drag ($C_d$) limits on top speed.
* Downforce ($C_l$) and load-sensitive tire friction.
* Centrifugal force limits on banked and flat corners.

## 📊 Results
*(Drag and drop your Daytona Figure 1-4 screenshots right here!)*

* **Daytona Lap Time:** 1:33.5 (Low Downforce Setup)
* **Le Mans Lap Time:** 3:25.0 (Low Downforce Setup)
* **Top Speeds:** 326 km/h at Daytona | 356 km/h at Le Mans
