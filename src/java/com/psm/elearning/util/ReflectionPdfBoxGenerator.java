package com.psm.elearning.util;

import javax.imageio.ImageIO;
import java.awt.Color;
import java.awt.Font;
import java.awt.Graphics2D;
import java.awt.RenderingHints;
import java.awt.image.BufferedImage;
import java.io.ByteArrayOutputStream;
import java.io.OutputStream;
import java.lang.reflect.Constructor;
import java.lang.reflect.Field;
import java.lang.reflect.Method;
import java.util.List;
import java.util.Map;

public final class ReflectionPdfBoxGenerator {

    private ReflectionPdfBoxGenerator() {
    }

    public static boolean isAvailable() {
        try {
            Class.forName("org.apache.pdfbox.pdmodel.PDDocument");
            Class.forName("org.apache.pdfbox.pdmodel.font.PDType1Font");
            Class.forName("org.apache.pdfbox.pdmodel.graphics.image.PDImageXObject");
            return true;
        } catch (ClassNotFoundException e) {
            return false;
        }
    }

    public static byte[] generatePdf(Map<String, Object> summary,
                                     List<Map<String, Object>> topCourses,
                                     List<Map<String, Object>> revenueRows,
                                     String title,
                                     String subtitle) throws Exception {
        Class<?> documentClass = Class.forName("org.apache.pdfbox.pdmodel.PDDocument");
        Class<?> pageClass = Class.forName("org.apache.pdfbox.pdmodel.PDPage");
        Class<?> contentStreamClass = Class.forName("org.apache.pdfbox.pdmodel.PDPageContentStream");
        Class<?> fontClass = Class.forName("org.apache.pdfbox.pdmodel.font.PDType1Font");
        Class<?> pdfontClass = Class.forName("org.apache.pdfbox.pdmodel.font.PDFont");
        Class<?> imageClass = Class.forName("org.apache.pdfbox.pdmodel.graphics.image.PDImageXObject");

        Object document = documentClass.getDeclaredConstructor().newInstance();
        Object page = pageClass.getDeclaredConstructor().newInstance();
        Method addPage = documentClass.getMethod("addPage", pageClass);
        addPage.invoke(document, page);

        Constructor<?> contentCtor = contentStreamClass.getConstructor(documentClass, pageClass);
        Object content = contentCtor.newInstance(document, page);

        Method beginText = contentStreamClass.getMethod("beginText");
        Method endText = contentStreamClass.getMethod("endText");
        Method setFont = contentStreamClass.getMethod("setFont", pdfontClass, float.class);
        Method newLineAtOffset = contentStreamClass.getMethod("newLineAtOffset", float.class, float.class);
        Method showText = contentStreamClass.getMethod("showText", String.class);
        Method drawImage = contentStreamClass.getMethod("drawImage", imageClass, float.class, float.class, float.class, float.class);
        Method closeContent = contentStreamClass.getMethod("close");

        Field helveticaBoldField = fontClass.getField("HELVETICA_BOLD");
        Object helveticaBold = helveticaBoldField.get(null);

        beginText.invoke(content);
        setFont.invoke(content, helveticaBold, 18f);
        newLineAtOffset.invoke(content, 50f, 760f);
        showText.invoke(content, sanitize(title == null ? "PSME Admin Report" : title));
        endText.invoke(content);

        beginText.invoke(content);
        setFont.invoke(content, helveticaBold, 10f);
        newLineAtOffset.invoke(content, 50f, 742f);
        showText.invoke(content, sanitize(subtitle == null ? "" : subtitle));
        endText.invoke(content);

        BufferedImage revenueChart = buildRevenueChart(revenueRows);
        ByteArrayOutputStream imageBuffer = new ByteArrayOutputStream();
        ImageIO.write(revenueChart, "png", imageBuffer);
        Method createFromByteArray = imageClass.getMethod("createFromByteArray", documentClass, byte[].class, String.class);
        Object chartImage = createFromByteArray.invoke(null, document, imageBuffer.toByteArray(), "revenue-chart");
        drawImage.invoke(content, chartImage, 50f, 500f, 520f, 180f);

        beginText.invoke(content);
        setFont.invoke(content, helveticaBold, 12f);
        newLineAtOffset.invoke(content, 50f, 470f);
        showText.invoke(content, "Top Courses by Enrollment");
        endText.invoke(content);

        float rowY = 452f;
        for (int i = 0; i < Math.min(8, topCourses.size()); i++) {
            Map<String, Object> row = topCourses.get(i);
            String text = (i + 1) + ". " + String.valueOf(row.getOrDefault("title", "Untitled")) + " | Enrollments: " + String.valueOf(row.getOrDefault("enrollments", 0));
            beginText.invoke(content);
            setFont.invoke(content, helveticaBold, 9f);
            newLineAtOffset.invoke(content, 60f, rowY - (i * 13f));
            showText.invoke(content, sanitize(text));
            endText.invoke(content);
        }

        closeContent.invoke(content);

        ByteArrayOutputStream out = new ByteArrayOutputStream();
        Method save = documentClass.getMethod("save", OutputStream.class);
        save.invoke(document, out);
        Method close = documentClass.getMethod("close");
        close.invoke(document);
        return out.toByteArray();
    }

    private static BufferedImage buildRevenueChart(List<Map<String, Object>> revenueRows) {
        int width = 620;
        int height = 180;
        BufferedImage image = new BufferedImage(width, height, BufferedImage.TYPE_INT_ARGB);
        Graphics2D g = image.createGraphics();
        try {
            g.setRenderingHint(RenderingHints.KEY_ANTIALIASING, RenderingHints.VALUE_ANTIALIAS_ON);
            g.setColor(Color.WHITE);
            g.fillRect(0, 0, width, height);
            g.setColor(new Color(15, 23, 42));
            g.setFont(new Font("SansSerif", Font.BOLD, 12));
            g.drawString("Revenue by Course", 12, 18);

            if (revenueRows == null || revenueRows.isEmpty()) {
                g.drawString("No revenue data available", 12, 42);
                return image;
            }

            int maxBars = Math.min(6, revenueRows.size());
            double maxValue = 1d;
            for (int i = 0; i < maxBars; i++) {
                maxValue = Math.max(maxValue, asDouble(revenueRows.get(i).get("revenue")));
            }

            int chartTop = 34;
            int chartBottom = height - 28;
            int chartHeight = chartBottom - chartTop;
            int barWidth = (width - 120) / maxBars;

            for (int i = 0; i < maxBars; i++) {
                Map<String, Object> row = revenueRows.get(i);
                double value = asDouble(row.get("revenue"));
                int barHeight = (int) Math.round((value / maxValue) * chartHeight);
                int barX = 86 + i * barWidth;
                int barY = chartBottom - barHeight;

                g.setColor(new Color(22, 101, 52));
                g.fillRoundRect(barX, barY, Math.max(24, barWidth - 16), barHeight, 8, 8);
                g.setColor(new Color(71, 85, 105));
                g.setFont(new Font("SansSerif", Font.PLAIN, 10));
                String label = String.valueOf(row.getOrDefault("title", "Untitled"));
                if (label.length() > 14) {
                    label = label.substring(0, 14) + "..";
                }
                g.drawString(label, barX, height - 10);
                g.drawString(String.format("NGN %, .0f", value), barX, barY - 4);
            }
        } finally {
            g.dispose();
        }
        return image;
    }

    private static double asDouble(Object value) {
        if (value == null) {
            return 0d;
        }
        try {
            return Double.parseDouble(String.valueOf(value));
        } catch (NumberFormatException ex) {
            return 0d;
        }
    }

    private static String sanitize(String value) {
        if (value == null) {
            return "";
        }
        return value.replace('\t', ' ').replaceAll("[^\\x20-\\x7E]", "?");
    }
}