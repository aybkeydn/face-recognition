% Test Framework: Yüz Tanıma Performans Testi
clear all; close all; clc;

% Test görüntüleri ve ground truth koordinatları
testImages = {'mustafa-kemal-ataturk.jpg', 'millitakım.jpg'}; % Test görselleri
groundTruth = {
    [50, 50, 100, 100; 150, 150, 100, 100], ... % mustafa-kemal-ataturk.jpg için ground truth
    [30, 30, 80, 80; 100, 100, 60, 60; 200, 200, 50, 50], ... % millitakım.jpg için ground truth
    
};

% Cascade Object Detector başlat
faceDetector = vision.CascadeObjectDetector();
faceDetector.MinSize = [20, 20]; % Küçük yüzler için minimum boyut
faceDetector.MergeThreshold = 4; % Algılama hassasiyeti

% Performans metriklerini başlat
totalTruePositives = 0;
totalFalsePositives = 0;
totalFalseNegatives = 0;

% Test görüntülerini döngüyle işleme
for i = 1:length(testImages)
    % Görüntüyü yükle ve ilgili ground truth koordinatlarını al
    image = imread(testImages{i});
    gtBoxes = groundTruth{i};

    % Görüntü işleme (Kontrast artırma)
    if size(image, 3) == 3
        % RGB görüntü için her bir kanalın kontrastını artır
        image(:,:,1) = imadjust(image(:,:,1)); % Kırmızı kanal
        image(:,:,2) = imadjust(image(:,:,2)); % Yeşil kanal
        image(:,:,3) = imadjust(image(:,:,3)); % Mavi kanal
    else
        % Gri tonlamalı görüntü için kontrast artır
        image = imadjust(image);
    end

    % Yüzleri tespit et
    detectedBoxes = step(faceDetector, image);

    % Algılanan kutuları ve ground truth'u kontrol et
    disp(['Algılanan Kutular (', testImages{i}, '):']);
    disp(detectedBoxes);
    disp(['Ground Truth Kutuları (', testImages{i}, '):']);
    disp(gtBoxes);

    % IoU metriğini hesapla
    if ~isempty(detectedBoxes) && ~isempty(gtBoxes)
        overlaps = bboxOverlapRatio(detectedBoxes, gtBoxes);
        disp(['IoU Değerleri (', testImages{i}, '):']);
        disp(overlaps);

        % Doğru pozitifler, yanlış pozitifler, ve yanlış negatifler
        truePositives = sum(overlaps > 0.3, 1); % IoU > 0.3
        falsePositives = size(detectedBoxes, 1) - sum(overlaps > 0.3, 1);
        falseNegatives = size(gtBoxes, 1) - sum(overlaps > 0.3, 2);
    else
        truePositives = 0;
        falsePositives = size(detectedBoxes, 1);
        falseNegatives = size(gtBoxes, 1);
    end

    % Toplam metriklere ekle
   
end