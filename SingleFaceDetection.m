% Proje: Yüz Tanıma Sistemi
clear all; close all; clc;

% Kullanıcıdan görüntü seçmesi
[file, path] = uigetfile({'*.jpg;*.png;*.jpeg', 'Görüntü Dosyaları (*.jpg, *.png, *.jpeg)'});
if isequal(file, 0)
    disp('Kullanıcı görüntü seçmedi.');
    return;
end
imagePath = fullfile(path, file);
image = imread(imagePath);

% Görüntüyü yeniden boyutlandır ve kontrast artır
[height, width, ~] = size(image);
if height > 320
    image = imresize(image, [320 NaN]);
end

if size(image, 3) == 3
    % RGB görüntü için her bir kanalın kontrastını artır
    image(:,:,1) = imadjust(image(:,:,1)); % Kırmızı kanal
    image(:,:,2) = imadjust(image(:,:,2)); % Yeşil kanal
    image(:,:,3) = imadjust(image(:,:,3)); % Mavi kanal
else
    % Gri tonlamalı görüntü için kontrast artır
    image = imadjust(image);
end

% Cascade Object Detector ile yüz tespiti
faceDetector = vision.CascadeObjectDetector();
faceDetector.MinSize = [40, 40]; % Daha küçük kutuları filtrelemek için minimum boyutu artır
faceDetector.MergeThreshold = 3; % Yanlış pozitifleri azaltmak için eşik ayarla
bboxes = step(faceDetector, image);

% Tespit edilen kutuları filtrele (çok küçük veya çok büyük kutuları çıkar)
filteredBBoxes = [];
for i = 1:size(bboxes, 1)
    % Kutu boyutlarını kontrol ederek filtreleme
    if bboxes(i, 3) > 30 && bboxes(i, 4) > 30 && bboxes(i, 3) < 150 && bboxes(i, 4) < 150
        filteredBBoxes = [filteredBBoxes; bboxes(i, :)];
    end
end

% IoU hesaplama için ground truth alın (örnek olarak)
groundTruth = [50, 50, 100, 100; 150, 150, 100, 100]; % Ground truth örneği
iouThreshold = 0.2; % IoU eşiği

% IoU metriğini hesapla
truePositives = 0;
falsePositives = 0;
falseNegatives = size(groundTruth, 1);

for i = 1:size(filteredBBoxes, 1)
    overlaps = bboxOverlapRatio(filteredBBoxes(i, :), groundTruth);
    if any(overlaps > iouThreshold)
        truePositives = truePositives + 1;
        falseNegatives = falseNegatives - 1;
    else
        falsePositives = falsePositives + 1;
    end
end

% Performans metriklerini hesapla
precision = truePositives / (truePositives + falsePositives);
recall = truePositives / (truePositives + falseNegatives);
f1Score = 2 * (precision * recall) / (precision + recall);

% Sonuçları ekrana yazdır
disp(['Precision: ', num2str(precision)]);
disp(['Recall: ', num2str(recall)]);
disp(['F1-Score: ', num2str(f1Score)]);

% Yüzleri görselleştir
figure;
imshow(image);
hold on;
for i = 1:size(filteredBBoxes, 1)
    rectangle('Position', filteredBBoxes(i, :), 'EdgeColor', 'r', 'LineWidth', 2);
    text(filteredBBoxes(i, 1), filteredBBoxes(i, 2) - 10, sprintf('Face %d', i), 'Color', 'r', 'FontSize', 10, 'FontWeight', 'bold');
end
hold off;
title('Cascade Object Detector ile Yüz Tanıma');
disp(['Tespit edilen yüz sayısı: ', num2str(size(filteredBBoxes, 1))]);


