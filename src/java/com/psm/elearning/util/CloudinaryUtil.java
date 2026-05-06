package com.psm.elearning.util;

import java.io.*;
import java.net.HttpURLConnection;
import java.net.URL;
import java.net.URLEncoder;
import java.nio.charset.StandardCharsets;
import java.security.MessageDigest;
import java.util.*;

/**
 * Cloudinary integration utility for uploading files to cloud storage.
 * Supports images, videos, and documents (course materials).
 */
public class CloudinaryUtil {

    private static String cloudName;
    private static String apiKey;
    private static String apiSecret;
    private static Properties props;

    static {
        loadConfig();
    }

    private static void loadConfig() {
        props = new Properties();
        try (InputStream in = CloudinaryUtil.class.getClassLoader().getResourceAsStream("cloudinary.properties")) {
            if (in != null) {
                props.load(in);
                cloudName = props.getProperty("cloudinary.cloud_name");
                apiKey = props.getProperty("cloudinary.api_key");
                apiSecret = props.getProperty("cloudinary.api_secret");
            }
        } catch (IOException e) {
            System.err.println("Failed to load cloudinary.properties: " + e.getMessage());
        }
    }

    /**
     * Upload a file to Cloudinary
     * @param fileBytes File content as byte array
     * @param fileName Original file name
     * @param folder Cloudinary folder (e.g., "psm/passports")
     * @param resourceType Resource type: "image", "video", or "raw" (for documents)
     * @return Cloudinary URL of uploaded file, or null if failed
     */
    public static String uploadFile(byte[] fileBytes, String fileName, String folder, String resourceType) {
        if (cloudName == null || apiKey == null || apiSecret == null) {
            System.err.println("Cloudinary credentials not configured");
            return null;
        }

        try {
            String uploadUrl = String.format("https://api.cloudinary.com/v1_1/%s/%s/upload", cloudName, resourceType);
            
            // Generate timestamp and signature
            long timestamp = System.currentTimeMillis() / 1000;
            
            Map<String, String> params = new TreeMap<>();
            params.put("folder", folder);
            params.put("timestamp", String.valueOf(timestamp));
            
            String signature = generateSignature(params);
            
            // Create multipart request
            String boundary = "----CloudinaryBoundary" + System.currentTimeMillis();
            URL url = new URL(uploadUrl);
            HttpURLConnection conn = (HttpURLConnection) url.openConnection();
            conn.setDoOutput(true);
            conn.setRequestMethod("POST");
            conn.setRequestProperty("Content-Type", "multipart/form-data; boundary=" + boundary);
            
            try (OutputStream out = conn.getOutputStream();
                 PrintWriter writer = new PrintWriter(new OutputStreamWriter(out, StandardCharsets.UTF_8), true)) {
                
                // Add file
                writer.append("--").append(boundary).append("\r\n");
                writer.append("Content-Disposition: form-data; name=\"file\"; filename=\"").append(fileName).append("\"\r\n");
                writer.append("Content-Type: application/octet-stream\r\n\r\n");
                writer.flush();
                out.write(fileBytes);
                out.flush();
                writer.append("\r\n");
                
                // Add other parameters
                addFormField(writer, boundary, "api_key", apiKey);
                addFormField(writer, boundary, "timestamp", String.valueOf(timestamp));
                addFormField(writer, boundary, "signature", signature);
                addFormField(writer, boundary, "folder", folder);
                
                writer.append("--").append(boundary).append("--\r\n");
                writer.flush();
            }
            
            int responseCode = conn.getResponseCode();
            if (responseCode == HttpURLConnection.HTTP_OK) {
                try (BufferedReader reader = new BufferedReader(new InputStreamReader(conn.getInputStream()))) {
                    StringBuilder response = new StringBuilder();
                    String line;
                    while ((line = reader.readLine()) != null) {
                        response.append(line);
                    }
                    
                    // Parse JSON response to get secure_url
                    String jsonResponse = response.toString();
                    int urlStart = jsonResponse.indexOf("\"secure_url\":\"") + 14;
                    int urlEnd = jsonResponse.indexOf("\"", urlStart);
                    if (urlStart > 13 && urlEnd > urlStart) {
                        return jsonResponse.substring(urlStart, urlEnd);
                    }
                }
            } else {
                try (BufferedReader reader = new BufferedReader(new InputStreamReader(conn.getErrorStream()))) {
                    StringBuilder errorResponse = new StringBuilder();
                    String line;
                    while ((line = reader.readLine()) != null) {
                        errorResponse.append(line);
                    }
                    System.err.println("Cloudinary upload failed: " + responseCode + " - " + errorResponse.toString());
                }
            }
        } catch (Exception e) {
            System.err.println("Cloudinary upload error: " + e.getMessage());
            e.printStackTrace();
        }
        
        return null;
    }

    private static void addFormField(PrintWriter writer, String boundary, String name, String value) {
        writer.append("--").append(boundary).append("\r\n");
        writer.append("Content-Disposition: form-data; name=\"").append(name).append("\"\r\n\r\n");
        writer.append(value).append("\r\n");
    }

    private static String generatePublicId(String fileName) {
        String nameWithoutExt = fileName.contains(".") ? fileName.substring(0, fileName.lastIndexOf(".")) : fileName;
        return nameWithoutExt.replaceAll("[^a-zA-Z0-9]", "_") + "_" + System.currentTimeMillis();
    }

    private static String generateSignature(Map<String, String> params) throws Exception {
        StringBuilder toSign = new StringBuilder();
        for (Map.Entry<String, String> entry : params.entrySet()) {
            if (toSign.length() > 0) toSign.append("&");
            toSign.append(entry.getKey()).append("=").append(entry.getValue());
        }
        toSign.append(apiSecret);
        
        MessageDigest digest = MessageDigest.getInstance("SHA-1");
        byte[] hash = digest.digest(toSign.toString().getBytes(StandardCharsets.UTF_8));
        return bytesToHex(hash);
    }
    
    private static String bytesToHex(byte[] bytes) {
        StringBuilder hexString = new StringBuilder();
        for (byte b : bytes) {
            String hex = Integer.toHexString(0xff & b);
            if (hex.length() == 1) hexString.append('0');
            hexString.append(hex);
        }
        return hexString.toString();
    }

    /**
     * Delete a file from Cloudinary by public ID
     */
    public static boolean deleteFile(String publicId, String resourceType) {
        if (cloudName == null || apiKey == null || apiSecret == null) {
            return false;
        }

        try {
            String deleteUrl = String.format("https://api.cloudinary.com/v1_1/%s/%s/destroy", cloudName, resourceType);
            long timestamp = System.currentTimeMillis() / 1000;
            
            Map<String, String> params = new TreeMap<>();
            params.put("public_id", publicId);
            params.put("timestamp", String.valueOf(timestamp));
            
            String signature = generateSignature(params);
            
            String postData = "public_id=" + URLEncoder.encode(publicId, "UTF-8") +
                            "&timestamp=" + timestamp +
                            "&api_key=" + apiKey +
                            "&signature=" + signature;
            
            URL url = new URL(deleteUrl);
            HttpURLConnection conn = (HttpURLConnection) url.openConnection();
            conn.setDoOutput(true);
            conn.setRequestMethod("POST");
            conn.setRequestProperty("Content-Type", "application/x-www-form-urlencoded");
            
            try (OutputStream out = conn.getOutputStream()) {
                out.write(postData.getBytes(StandardCharsets.UTF_8));
            }
            
            return conn.getResponseCode() == HttpURLConnection.HTTP_OK;
        } catch (Exception e) {
            System.err.println("Cloudinary delete error: " + e.getMessage());
            return false;
        }
    }

    public static String getPassportFolder() {
        return props.getProperty("cloudinary.folder_passports", "psm/passports");
    }

    public static String getMaterialsFolder() {
        return props.getProperty("cloudinary.folder_materials", "psm/materials");
    }

    public static String getCertificatesFolder() {
        return props.getProperty("cloudinary.folder_certificates", "psm/certificates");
    }

    public static String getAssessmentAnswersFolder() {
        return props.getProperty("cloudinary.folder_assessment_answers", "psm/assessment-answers");
    }

    public static String getAssessmentAttachmentsFolder() {
        return props.getProperty("cloudinary.folder_assessment_attachments", "psm/assessment-attachments");
    }

    public static String getCourseBannersFolder() {
        return props.getProperty("cloudinary.folder_course_banners", "psm/course-banners");
    }

}
