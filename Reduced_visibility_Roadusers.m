%% Clean workspace and close all
clear all;
close all;
clc;

%% Constraint for parameter
Vss_kmph_EV=88.5;                           %Velocity of Ego vehicle in kmph
Vss_mps_EV=Vss_kmph_EV/3.6;
AVlongdecEB=-7;                             %Maximum deceleration, amax(m/s^2)
G=0;                                        %Grade of road(unitless)
SD=0.25;                                    %Safe distance between rear target vehicle and ego vehicle(m)
tpr=2.5;                                    %Brake reaction time of driver (time required for perception and reaction)(s)
SFDCarSS=2;
SignF=-1;

TTC_arr=[];
speed=[];
FFHTI=[];

d1= abs((Vss_kmph_EV^2)/(254*((AVlongdecEB/9.81)+(G/100))));            %Stopping distance of the front vehicle(Ego vehicle)(m)

for Vss_kmph_TV=70:0.5:88.5
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
    TTC=ftti_2;
else
    TTC=ftti_1;
end
%% FHTI calculation 
for j = 0.01 : 0.01 : TTC
    Dist_A = 0.5 * -a * j^2;
    VV = sqrt(Vss_mps_TV^2 + 2 * Dist_A * -a);
    Dist_B = -VV^2/(2*AVlongdecEB);
    if sign(((Dist_A + Dist_B) - s)) ~= sign(SignF)
        break;
    else
        signF = sign(((Dist_A + Dist_B) - s));
    end
end
FHTI = j;

FFHTI=[FFHTI FHTI];
TTC_arr=[TTC_arr TTC];
speed=[speed Vss_kmph_TV];
end

figure(1);
plot(speed,FFHTI);
grid on
xlabel('TV velocity in KMPH')
ylabel('Fault Handling Time Interval in sec');
hold on

f=gcf;
saveas(f,'Reduced_visibility_Roadusers_FHTI.jpg');

figure(2);
plot(speed,TTC_arr);
grid on
xlabel('TV velocity in KMPH')
ylabel('Time-to-collision in sec');
hold on


f=gcf;
saveas(f,'Reduced_visibility_Roadusers_TTC.jpg');

x_speed=speed';
y_TTC=TTC_arr';
z_FHTI=FFHTI';
data={'Vehicle_Speed','TTC','FHTI'};
xlswrite('Functional_Safety_Scenarios',data,'Reduced_visibility_Roadusers','A1');
xlswrite('Functional_Safety_Scenarios',x_speed,'Reduced_visibility_Roadusers','A2');
xlswrite('Functional_Safety_Scenarios',y_TTC,'Reduced_visibility_Roadusers','B2');
xlswrite('Functional_Safety_Scenarios',z_FHTI,'Reduced_visibility_Roadusers','C2');

folder = pwd;
excelFileName = 'Functional_Safety_Scenarios.xls';
fullFileName = fullfile(folder, excelFileName);
objExcel = actxserver('Excel.Application');
objExcel.Visible = true;
ExcelWorkbook = objExcel.Workbooks.Open(fullFileName);
oSheet = objExcel.ActiveSheet;
imageFolder = fileparts(which('Reduced_visibility_Roadusers_TTC.jpg'));
imageFullFileName = fullfile(imageFolder, 'Reduced_visibility_Roadusers_TTC.jpg');
Shapes = oSheet.Shapes;
Shapes.AddPicture(imageFullFileName, 0, 1, 400, 20, 400, 300);

imageFolder1 = fileparts(which('Reduced_visibility_Roadusers_FHTI.jpg'));
imageFullFileName1 = fullfile(imageFolder, 'Reduced_visibility_Roadusers_FHTI.jpg');
Shapes.AddPicture(imageFullFileName1, 0, 1, 850, 20, 400, 300);

objExcel.DisplayAlerts = false;
ExcelWorkbook.SaveAs(fullFileName);
ExcelWorkbook.Close(false);
objExcel.Quit; 
