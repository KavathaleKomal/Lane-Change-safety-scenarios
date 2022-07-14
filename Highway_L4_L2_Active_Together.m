%% Clean workspace and close all
clear all;
clc;
close all
%% Constraint for parameter

Vss_kmph_EV=88.5;                           %Velocity of Ego vehicle in kmph
Vss_mps_EV=Vss_kmph_EV/3.6;
AVlongdecEB=-7;                             %Maximum deceleration, amax(m/s^2)
MaxRecdecl=-7;
G=0;                                        %Grade of road(unitless)
SD=0.25;                                    %Safe distance between rear target vehicle and ego vehicle(m)
tpr=2.5;                                    %Brake reaction time of driver (time required for perception and reaction)(s)
SignF=-1;
SFDCarSS=2;

d1= abs((Vss_kmph_EV^2)/(254*((AVlongdecEB/9.81)+(G/100))));            %Stopping distance of the front vehicle(Ego vehicle)(m)

TTC_arr=[];
speed=[];
FFHTI=[];

for Vss_kmph_TV=40:0.5:88.5
Vss_mps_TV=Vss_kmph_TV/3.6;
d2=0.278*Vss_kmph_TV*tpr;
SD=SFDCarSS*Vss_kmph_TV*0.2778;                      
s1=SD+d1;                                                            
s=s1-d2; 

%% TTC calculation 
a=-(9.81*(Vss_kmph_TV*Vss_kmph_TV/(254*s)));
TV_delec_dist=-Vss_mps_TV*Vss_mps_TV/(2*a);

ftti_1=(-Vss_mps_TV+sqrt(Vss_mps_TV*Vss_mps_TV+2*(-a)*s))/(-a);
ftti_2=(-Vss_mps_TV-sqrt(Vss_mps_TV*Vss_mps_TV+2*(-a)*s))/(-a);
if ftti_1<0
    FTTI=ftti_2;
else
    FTTI=ftti_1;
end

%% FHTI calculation
for j = 0.01 : 0.01 : FTTI
    Dist_A =Vss_mps_TV*j+ 0.5 * -a * j^2;
    VV = Vss_mps_TV+(-a)*j;
    Dist_B = VV*j+0.5 * MaxRecdecl * j^2;
    if sign(((Dist_A + Dist_B) - s)) ~= sign(SignF)
        break;
    else
        signF = sign(((Dist_A + Dist_B) - s));
    end
end
FHTI=j;
TTC_arr=[TTC_arr FTTI];
speed=[speed Vss_kmph_TV];
FFHTI=[FFHTI FHTI];
end
%% plots 
figure(1);
plot(speed,TTC_arr);
grid on
xlabel('TV velocity in KMPH')
ylabel('Time-to-collision in sec');
hold on

f=gcf;
saveas(f,'Highway_L4_L2_Active_Together_TTC.jpg');

figure(2);
plot(speed,FFHTI);
grid on
xlabel('TV velocity in KMPH')
ylabel('Fault Handling Time Interval in sec');
hold on



f=gcf;
saveas(f,'Highway_L4_L2_Active_Together_FHTI.jpg');

%% excel write

x_speed=speed';
y_TTC=TTC_arr';
z_FHTI=FFHTI';
data={'Vehicle_Speed','TTC','FHTI'};
xlswrite('Functional_Safety_Scenarios',data,'Highway_L4_L2_Active_Together','A1');
xlswrite('Functional_Safety_Scenarios',x_speed,'Highway_L4_L2_Active_Together','A2');
xlswrite('Functional_Safety_Scenarios',y_TTC,'Highway_L4_L2_Active_Together','B2');
xlswrite('Functional_Safety_Scenarios',z_FHTI,'Highway_L4_L2_Active_Together','C2');

folder = pwd;
excelFileName = 'Functional_Safety_Scenarios.xls';
fullFileName = fullfile(folder, excelFileName);
objExcel = actxserver('Excel.Application');
objExcel.Visible = true;
ExcelWorkbook = objExcel.Workbooks.Open(fullFileName);
oSheet = objExcel.ActiveSheet;
imageFolder = fileparts(which('Highway_L4_L2_Active_Together_TTC.jpg'));
imageFullFileName = fullfile(imageFolder, 'Highway_L4_L2_Active_Together_TTC.jpg');
Shapes = oSheet.Shapes;
Shapes.AddPicture(imageFullFileName, 0, 1, 400, 20, 400, 300);

imageFolder1 = fileparts(which('Highway_L4_L2_Active_Together_FHTI.jpg'));
imageFullFileName1 = fullfile(imageFolder, 'Highway_L4_L2_Active_Together_FHTI.jpg');
Shapes.AddPicture(imageFullFileName1, 0, 1, 850, 20, 400, 300);

objExcel.DisplayAlerts = false;
ExcelWorkbook.SaveAs(fullFileName);
ExcelWorkbook.Close(false);
objExcel.Quit; 