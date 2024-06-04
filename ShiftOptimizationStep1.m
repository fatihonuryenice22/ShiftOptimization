
data = readtable('C:\Users\PC\Desktop\BitirmeDataSet.xlsx');


dates = datetime(data.Date, 'InputFormat', 'MM/dd/yyyy hh:mm:ss a'); % Tarihler
sales = data.Sales; % Satışlar
traffic = data.Traffic; % Trafik
staff = data.Staff; % Personel sayısı

p = 4; % Modelin derecesi
model = ar(sales, p);


model_params = estimate(model, sales);

summary(model_params);


y_pred = predict(model, sales, length(sales));


residuals = sales - y_pred;


figure;
subplot(2,1,1);
plot(sales, '-o');
hold on;
plot(y_pred, '-x');
legend('Gerçek Veri', 'Tahmin Edilen Değerler');
title('Gerçek ve Tahmin Edilen Değerler');

subplot(2,1,2);
plot(residuals, '-o');
title('Artıklar');


SSR = sum((sales - y_pred).^2); % Residual Sum of Squares
SST = sum((sales - mean(sales)).^2); % Total Sum of Squares
R_squared = 1 - (SSR / SST);

disp(['R-kare: ', num2str(R_squared)]);% Modeli özetleme
summary(model_params);


y_pred = predict(model, sales, length(sales));


residuals = sales - y_pred;


figure;
subplot(2,1,1);
plot(sales, '-o');
hold on;
plot(y_pred, '-x');
legend('Gerçek Veri', 'Tahmin Edilen Değerler');
title('Gerçek ve Tahmin Edilen Değerler');

subplot(2,1,2);
plot(residuals, '-o');
title('Artıklar');

% R-Kare Değeri
SSR = sum((sales - y_pred).^2); % Residual Sum of Squares
SST = sum((sales - mean(sales)).^2); % Total Sum of Squares
R_squared = 1 - (SSR / SST);

disp(['R-kare: ', num2str(R_squared)]);% Parametrelerin tahminleri
intercept = model_params.A;
traffic_coeff = model_params.B;
staff_coeff = model_params.C;
ar_params = model_params.AR;

% R-Kare Değeri
R_squared = 1 - (SSR / SST);

% Sonuçların tablosunu oluşturma
T = table(intercept, traffic_coeff, staff_coeff, ar_params, R_squared, 'VariableNames', {'Intercept', 'TrafficCoeff', 'StaffCoeff', 'ARParams', 'R_squared'});
disp(T);


