package com.psm.elearning.util;

import com.google.zxing.BarcodeFormat;
import com.google.zxing.EncodeHintType;
import com.google.zxing.WriterException;
import com.google.zxing.client.j2se.MatrixToImageWriter;
import com.google.zxing.common.BitMatrix;
import com.google.zxing.qrcode.QRCodeWriter;
import com.google.zxing.qrcode.decoder.ErrorCorrectionLevel;

import java.io.ByteArrayOutputStream;
import java.io.File;
import java.io.IOException;
import java.nio.file.FileSystems;
import java.nio.file.Path;
import java.util.HashMap;
import java.util.Map;

/**
 * QR Code Utility for generating QR codes for certificate verification
 * Uses ZXing (Zebra Crossing) library for QR code generation
 * 
 * @author PSM E-Learning Team
 * @version 1.0
 */
public class QRUtil {
    
    private static final int QR_CODE_WIDTH = 300;
    private static final int QR_CODE_HEIGHT = 300;
    private static final String QR_CODE_FORMAT = "PNG";
    
    /**
     * Generates a QR code image and saves it to the specified path
     * 
     * @param data Data to encode in the QR code (e.g., verification URL)
     * @param filePath Full file path where QR code image will be saved
     * @return true if QR code generated successfully, false otherwise
     */
    public static boolean generateQRCode(String data, String filePath) {
        try {
            // Create directories if they don't exist
            File file = new File(filePath);
            File parentDir = file.getParentFile();
            if (parentDir != null && !parentDir.exists()) {
                parentDir.mkdirs();
            }
            
            // Configure QR code parameters
            Map<EncodeHintType, Object> hints = new HashMap<>();
            hints.put(EncodeHintType.ERROR_CORRECTION, ErrorCorrectionLevel.H);
            hints.put(EncodeHintType.CHARACTER_SET, "UTF-8");
            hints.put(EncodeHintType.MARGIN, 1);
            
            // Generate QR code
            QRCodeWriter qrCodeWriter = new QRCodeWriter();
            BitMatrix bitMatrix = qrCodeWriter.encode(
                data, 
                BarcodeFormat.QR_CODE, 
                QR_CODE_WIDTH, 
                QR_CODE_HEIGHT, 
                hints
            );
            
            // Save QR code as image
            Path path = FileSystems.getDefault().getPath(filePath);
            MatrixToImageWriter.writeToPath(bitMatrix, QR_CODE_FORMAT, path);
            
            System.out.println("QR Code generated successfully: " + filePath);
            return true;
            
        } catch (WriterException | IOException e) {
            System.err.println("Failed to generate QR code: " + e.getMessage());
            e.printStackTrace();
            return false;
        }
    }

    /**
     * Generates a QR code image as byte array (PNG).
     *
     * @param data Data to encode in the QR code
     * @return PNG bytes or null on failure
     */
    public static byte[] generateQRCodeBytes(String data) {
        try {
            Map<EncodeHintType, Object> hints = new HashMap<>();
            hints.put(EncodeHintType.ERROR_CORRECTION, ErrorCorrectionLevel.H);
            hints.put(EncodeHintType.CHARACTER_SET, "UTF-8");
            hints.put(EncodeHintType.MARGIN, 1);

            QRCodeWriter qrCodeWriter = new QRCodeWriter();
            BitMatrix bitMatrix = qrCodeWriter.encode(
                data,
                BarcodeFormat.QR_CODE,
                QR_CODE_WIDTH,
                QR_CODE_HEIGHT,
                hints
            );

            try (ByteArrayOutputStream out = new ByteArrayOutputStream()) {
                MatrixToImageWriter.writeToStream(bitMatrix, QR_CODE_FORMAT, out);
                return out.toByteArray();
            }
        } catch (WriterException | IOException e) {
            System.err.println("Failed to generate QR code bytes: " + e.getMessage());
            return null;
        }
    }
    
    /**
     * Generates a QR code for certificate verification
     * 
     * @param certificateNumber Unique certificate number
     * @param enrollmentID Enrollment ID
     * @param baseURL Base URL for verification (e.g., "https://psmelearning.com/verify")
     * @param outputPath Full file path where QR code will be saved
     * @return true if QR code generated successfully
     */
    public static boolean generateCertificateQRCode(
            String certificateNumber, 
            int enrollmentID, 
            String baseURL, 
            String outputPath) {
        
        // Construct verification URL
        String verificationURL = baseURL + "?cert=" + certificateNumber + "&eid=" + enrollmentID;
        
        return generateQRCode(verificationURL, outputPath);
    }
    
    /**
     * Generates a simple verification URL for a certificate
     * 
     * @param certificateNumber Unique certificate number
     * @param baseURL Base URL for verification
     * @return Full verification URL
     */
    public static String generateVerificationURL(String certificateNumber, String baseURL) {
        return baseURL + "?cert=" + certificateNumber;
    }
    
    /**
     * Generates a unique certificate number
     * Format: PSM-YYYY-XXXXX (e.g., PSM-2025-00001)
     * 
     * @param enrollmentID Enrollment ID to include in certificate number
     * @return Generated certificate number
     */
    public static String generateCertificateNumber(int enrollmentID) {
        int year = java.time.Year.now().getValue();
        String paddedID = String.format("%05d", enrollmentID);
        return "PSM-" + year + "-" + paddedID;
    }
    
    /**
     * Validates a certificate number format
     * 
     * @param certificateNumber Certificate number to validate
     * @return true if format is valid
     */
    public static boolean isValidCertificateNumber(String certificateNumber) {
        if (certificateNumber == null || certificateNumber.isEmpty()) {
            return false;
        }
        
        // Expected format: PSM-YYYY-XXXXX
        String pattern = "^PSM-\\d{4}-\\d{5}$";
        return certificateNumber.matches(pattern);
    }
    
    /**
     * Deletes a QR code file
     * 
     * @param filePath Path to the QR code file
     * @return true if file deleted successfully
     */
    public static boolean deleteQRCode(String filePath) {
        try {
            File file = new File(filePath);
            if (file.exists()) {
                boolean deleted = file.delete();
                if (deleted) {
                    System.out.println("QR Code deleted: " + filePath);
                }
                return deleted;
            }
            return false;
        } catch (Exception e) {
            System.err.println("Failed to delete QR code: " + e.getMessage());
            return false;
        }
    }
}
