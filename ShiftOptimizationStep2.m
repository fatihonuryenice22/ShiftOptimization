% Dosya yolunu belirleme
filePath = 'C:\Users\PC\Desktop\BitirmeDataSet.xlsx';

% Dosyanın mevcut olup olmadığını kontrol etme
if isfile(filePath)
    % Dosya mevcutsa oku
    data = readtable(filePath, 'VariableNamingRule', 'preserve');
    disp('Dosya başarıyla yüklendi.');
    
    % Sütun adlarını görüntüleme
    disp(data.Properties.VariableNames);
    
    % Veriyi datetime formatına dönüştürme
    data.Date = datetime(data.Date, 'InputFormat', 'MM/dd/yyyy hh:mm:ss a');
    
    % Veriyi tarih sütununa göre sıralama
    sorted_data = sortrows(data, 'Date');
    
    % Zaman dilimlerini belirleme (Ocak ayının ilk 10 günü, ikinci 10 günü, son 11 günü)
    time_periods = {
        sorted_data(sorted_data.Date < datetime('2023-01-11'), :), ...
        sorted_data(sorted_data.Date >= datetime('2023-01-11') & sorted_data.Date < datetime('2023-01-21'), :), ...
        sorted_data(sorted_data.Date >= datetime('2023-01-21') & sorted_data.Date < datetime('2023-02-01'), :)
    };
    
    % Her zaman dilimi için model tahminleri
    results = cell(length(time_periods), 1);
    for i = 1:length(time_periods)
        period_data = time_periods{i};
        sales = period_data.Sales;
        time = period_data.Date;
        
        % Hücre dizisini sayısal türe dönüştürme
        if iscell(sales)
            sales = cellfun(@str2double, sales);
        end
        
        % ARIMA(3,0,0) modelini kullanarak tahmin etme
        p = 3; % Modelin derecesi
        model = arima(p, 0, 0); % AR(p) modeli
        estimated_model = estimate(model, sales);
        
        % RMSE hesaplama
        y_pred = forecast(estimated_model, length(sales), 'Y0', sales);
        residuals = sales - y_pred;
        rmse = sqrt(mean(residuals.^2));
        
        % Sonuçları kaydetme
        results{i} = struct('model', estimated_model, 'RMSE', rmse);
    end
    
    % Sonuçları tablo formatında görüntüleme
    disp('Model Tahmin Sonuçları:');
    for i = 1:length(time_periods)
        fprintf('Zaman Dilimi %d:\n', i);
        present(results{i}.model);
        fprintf('RMSE: %.3f\n', results{i}.RMSE);
        disp('-----------------------------');
    end
    
else
    % Dosya mevcut değilse hata mesajı göster
    error('Dosya bulunamadı. Dosya yolunu kontrol edin.');
end
