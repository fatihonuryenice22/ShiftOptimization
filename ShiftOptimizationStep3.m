% Gerekli parametrelerin belirlenmesi
g = 0.3; % Brüt kar marjı
d = 100;  % Ücret oranı (saatlik ücret)
alpha = 1; % Satış potansiyelini etkileyen parametre
beta1 = 0.5; % Satış elemanı sayısının etkisi
beta2 = 0.2; % Satış elemanının etkisini belirleyen ikinci parametre
rho = 0.8; % Artıkların otoregresif katsayısı
nu_t = 1; % Tahmin hatası varyansı
tc = 10; % Örnek alınan periyot sayısı
E_sum = 1; % Toplam artıklar (örnek değer)

% ARIMA modeli ve tahmin edilen değerler (önceki adımlardan)
filePath = 'C:\Users\PC\Desktop\BitirmeDataSet.xlsx';

if isfile(filePath)
    data = readtable(filePath, 'VariableNamingRule', 'preserve');
    data.Date = datetime(data.Date, 'InputFormat', 'MM/dd/yyyy hh:mm:ss a');
    sorted_data = sortrows(data, 'Date');
    time_periods = {
        sorted_data(sorted_data.Date < datetime('2023-01-11'), :), ...
        sorted_data(sorted_data.Date >= datetime('2023-01-11') & sorted_data.Date < datetime('2023-01-21'), :), ...
        sorted_data(sorted_data.Date >= datetime('2023-01-21') & sorted_data.Date < datetime('2023-02-01'), :)
    };

    results = cell(length(time_periods), 1);
    for i = 1:length(time_periods)
        period_data = time_periods{i};
        sales = period_data.Sales;
        time = period_data.Date;

        if iscell(sales)
            sales = cellfun(@str2double, sales);
        end

        p = 3; % Modelin derecesi
        model = arima(p, 0, 0); % AR(p) modeli
        estimated_model = estimate(model, sales);
        y_pred = forecast(estimated_model, length(sales), 'Y0', sales);
        residuals = sales - y_pred;
        rmse = sqrt(mean(residuals.^2));
        results{i} = struct('model', estimated_model, 'y_pred', y_pred, 'residuals', residuals, 'RMSE', rmse);
    end

    y_pred = results{1}.y_pred;
    epsilon = results{1}.residuals; % Tahmin edilen artıklara dayalı olarak epsilon

    % E_sum'i hesaplarken epsilon'u kullanma (örneğin son 3 değeri alalım)
    n = 1; % Son 3 değeri alalım
    E_sum = sum(rho .^ (1:n) .* epsilon(end-n+1:end));

    % Denklem fonksiyonunun tanımlanması
    fun = @(N) -g * alpha * beta2 * N^beta1 * exp(E_sum) + 0.5 * nu_t * (1 / tc^2) * exp(beta2 / tc) - d;

    % Başlangıç tahmini (initial guess)
    staff_initial_guess = 5;

    % fsolve kullanarak sayısal çözüm
    options = optimoptions('fsolve', 'Display', 'iter');
    optimal_staff = fsolve(fun, staff_initial_guess, options);

    disp(['Optimal Personel Sayısı: ', num2str(optimal_staff)]);

else
    error('Dosya bulunamadı. Dosya yolunu kontrol edin.');
end
