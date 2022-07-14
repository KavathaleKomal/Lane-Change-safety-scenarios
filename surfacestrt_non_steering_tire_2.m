%% Clean workspace and close all
clear all
close all
clc
%% Constraint for parameter

KK = 0;

    Speed = [];
    TimeDur = [];
    DataTTC = [];
    for EgoVehicleSpeed = 40 : 5 : 88.5
        
        Vx_EV = EgoVehicleSpeed/3.6;
        Dist2Bondary = 0.3;
       
        %%
        LaneWidth = 3.66;
        TruckWidth = 3.05;
        WheelBase = 5.79;
        Ay = -0.1*9.81;
        AyComp = -Ay;
        % Saturation: If acceleration is more than 1g. Need to saturate
        if abs(AyComp) > 9.81
            AyComp = sign(AyComp)*9.81;
        else
            AyComp = AyComp;
        end
        
        dT = 0.01;
        VelY = 0;
        DistCovered = 0;
        K = 0;
 %% TTC computation
        Flag = false;
        while(Flag == false)
            VelY = VelY + dT * Ay;
            DistCovered = DistCovered + dT*VelY;
            K = K + 1;
            if (abs(DistCovered) >= Dist2Bondary)
                Flag = true;
            end
        end
        TTC = K * dT;
        %% Dist covered during response time
        for ijk = TTC : -dT : 0.001
           
        IC = 0;
        VelY = 0;
        DistCovered = 0;
        Flag = false;
        C = 0;
        %% FHTI calculation
        for i = 0 : dT : ijk
            VelY = VelY + dT * Ay;
            DistCovered = DistCovered + dT*VelY;
        end
        DistCovered1 = abs(DistCovered);
 %% 
 
        Flag = false;
        N = 0;
        Pev_VelY = VelY;
        DistCovered = 0;
        while(Flag == false)
            
            VelY = VelY + dT * AyComp;
            DistCovered = DistCovered + dT*VelY;
            if sign(VelY) ~= sign(Pev_VelY)
                Flag = true;
            end
            N = N + 1;
        end
        
        DistCovered2 = abs(DistCovered);
        TotalDist = DistCovered1 + DistCovered2;
        if abs(TotalDist) < (Dist2Bondary-0.05)
            break;
        end
        end
        Speed = [Speed EgoVehicleSpeed];
        TimeDur = [TimeDur ijk];
        DataTTC = [DataTTC TTC];
     
    end
    
    
%% Plots
figure(1);
plot(Speed,DataTTC);
grid on
xlabel('EV velocity in KMPH')
ylabel('Time-to-collision in sec');
hold on

f=gcf;
saveas(f,'surfacestrt_non_steering_tire_2_TTC.jpg');

figure(2);
plot(Speed,TimeDur);
grid on
xlabel('TV velocity in KMPH')
ylabel('Fault Handling Time Interval in sec');
hold on

f=gcf;
saveas(f,'surfacestrt_non_steering_tire_2_FHTI.jpg');

%% excel write
x_speed=Speed';
y_TTC=DataTTC';
z_FHTI=TimeDur';
data={'Vehicle_Speed','TTC','FHTI'};
xlswrite('Functional_Safety_Scenarios',data,'surfacestrt_non_steering_tire_2','A1');
xlswrite('Functional_Safety_Scenarios',x_speed,'surfacestrt_non_steering_tire_2','A2');
xlswrite('Functional_Safety_Scenarios',y_TTC,'surfacestrt_non_steering_tire_2','B2');
xlswrite('Functional_Safety_Scenarios',z_FHTI,'surfacestrt_non_steering_tire_2','C2');

folder = pwd;
excelFileName = 'Functional_Safety_Scenarios.xls';
fullFileName = fullfile(folder, excelFileName);
objExcel = actxserver('Excel.Application');
objExcel.Visible = true;
ExcelWorkbook = objExcel.Workbooks.Open(fullFileName);
oSheet = objExcel.ActiveSheet;
imageFolder = fileparts(which('surfacestrt_non_steering_tire_2_TTC.jpg'));
imageFullFileName = fullfile(imageFolder, 'surfacestrt_non_steering_tire_2_TTC.jpg');
Shapes = oSheet.Shapes;
Shapes.AddPicture(imageFullFileName, 0, 1, 400, 20, 400, 300);

imageFolder1 = fileparts(which('surfacestrt_non_steering_tire_2_FHTI.jpg'));
imageFullFileName1 = fullfile(imageFolder, 'surfacestrt_non_steering_tire_2_FHTI.jpg');
Shapes.AddPicture(imageFullFileName1, 0, 1, 850, 20, 400, 300);

objExcel.DisplayAlerts = false;
ExcelWorkbook.SaveAs(fullFileName);
ExcelWorkbook.Close(false);
objExcel.Quit; 