package com.psm.elearning.util;

import java.io.ByteArrayOutputStream;
import java.io.IOException;
import java.nio.charset.StandardCharsets;
import java.util.ArrayList;
import java.util.LinkedHashMap;
import java.util.List;
import java.util.Map;

public final class SimplePdfWriter {

    private static final int PAGE_WIDTH = 842;
    private static final int PAGE_HEIGHT = 595;
    private static final int LEFT_MARGIN = 36;
    private static final int TOP_MARGIN = 40;
    private static final int BOTTOM_MARGIN = 36;
    private static final int LINE_HEIGHT = 14;
    private static final int MAX_CHARS_PER_LINE = 96;
    private static final int MAX_LINES_PER_PAGE = (PAGE_HEIGHT - TOP_MARGIN - BOTTOM_MARGIN) / LINE_HEIGHT;

    private SimplePdfWriter() {
    }

    public static byte[] writeTextPdf(String title, List<String> lines) throws IOException {
        List<String> normalizedLines = new ArrayList<>();
        normalizedLines.add(sanitize(title));
        normalizedLines.add("");
        for (String line : lines) {
            normalizedLines.addAll(wrapLine(sanitize(line)));
        }

        List<List<String>> pages = paginate(normalizedLines, MAX_LINES_PER_PAGE);
        List<byte[]> objects = new ArrayList<>();

        objects.add(object(1, "<< /Type /Catalog /Pages 2 0 R >>"));
        StringBuilder pagesDict = new StringBuilder("<< /Type /Pages /Kids [");
        for (int i = 0; i < pages.size(); i++) {
            int pageObjNumber = 4 + (i * 2);
            pagesDict.append(pageObjNumber).append(" 0 R ");
        }
        pagesDict.append("] /Count ").append(pages.size()).append(" >>");
        objects.add(object(2, pagesDict.toString()));
        objects.add(object(3, "<< /Type /Font /Subtype /Type1 /BaseFont /Helvetica >>"));

        for (int i = 0; i < pages.size(); i++) {
            int pageObjNumber = 4 + (i * 2);
            int contentObjNumber = pageObjNumber + 1;
            List<String> pageLines = pages.get(i);
            String contentStream = buildContentStream(pageLines, i == 0);
            byte[] contentBytes = contentStream.getBytes(StandardCharsets.US_ASCII);
            objects.add(object(pageObjNumber,
                    "<< /Type /Page /Parent 2 0 R /MediaBox [0 0 " + PAGE_WIDTH + " " + PAGE_HEIGHT + "] /Resources << /Font << /F1 3 0 R >> >> /Contents " + contentObjNumber + " 0 R >>"));
            objects.add(streamObject(contentObjNumber, contentBytes));
        }

        ByteArrayOutputStream output = new ByteArrayOutputStream();
        output.write("%PDF-1.4\n".getBytes(StandardCharsets.US_ASCII));

        List<Integer> offsets = new ArrayList<>();
        offsets.add(0);
        for (byte[] object : objects) {
            offsets.add(output.size());
            output.write(object);
        }

        int xrefStart = output.size();
        int objectCount = objects.size() + 1;
        StringBuilder xref = new StringBuilder();
        xref.append("xref\n0 ").append(objectCount).append("\n");
        xref.append("0000000000 65535 f \n");
        for (int i = 1; i < objectCount; i++) {
            xref.append(String.format("%010d 00000 n \n", offsets.get(i)));
        }
        output.write(xref.toString().getBytes(StandardCharsets.US_ASCII));

        String trailer = "trailer\n<< /Size " + objectCount + " /Root 1 0 R >>\nstartxref\n" + xrefStart + "\n%%EOF";
        output.write(trailer.getBytes(StandardCharsets.US_ASCII));
        return output.toByteArray();
    }

    public static byte[] writeBrandedPdf(String title, String subtitle, List<String> lines) throws IOException {
        List<Section> sections = parseSections(lines);
        List<String> normalizedLines = new ArrayList<>();
        normalizedLines.add("[TITLE]" + sanitize(title));
        normalizedLines.add("[SUBTITLE]" + sanitize(subtitle));
        for (Section section : sections) {
            normalizedLines.add("[SECTION]" + section.title);
            for (String item : section.items) {
                normalizedLines.add("  " + item);
            }
            normalizedLines.add("");
        }

        List<List<String>> pages = paginate(normalizedLines, MAX_LINES_PER_PAGE - 3); // reserve space for header
        List<byte[]> objects = new ArrayList<>();

        objects.add(object(1, "<< /Type /Catalog /Pages 2 0 R >>"));
        StringBuilder pagesDict = new StringBuilder("<< /Type /Pages /Kids [");
        for (int i = 0; i < pages.size(); i++) {
            int pageObjNumber = 4 + (i * 2);
            pagesDict.append(pageObjNumber).append(" 0 R ");
        }
        pagesDict.append("] /Count ").append(pages.size()).append(" >>");
        objects.add(object(2, pagesDict.toString()));
        objects.add(object(3, "<< /Type /Font /Subtype /Type1 /BaseFont /Helvetica >>"));

        for (int i = 0; i < pages.size(); i++) {
            int pageObjNumber = 4 + (i * 2);
            int contentObjNumber = pageObjNumber + 1;
            List<String> pageLines = pages.get(i);
            String contentStream = buildContentStreamWithHeader(pageLines, i == 0, title, subtitle, i + 1, pages.size());
            byte[] contentBytes = contentStream.getBytes(StandardCharsets.US_ASCII);
            objects.add(object(pageObjNumber,
                    "<< /Type /Page /Parent 2 0 R /MediaBox [0 0 " + PAGE_WIDTH + " " + PAGE_HEIGHT + "] /Resources << /Font << /F1 3 0 R >> >> /Contents " + contentObjNumber + " 0 R >>"));
            objects.add(streamObject(contentObjNumber, contentBytes));
        }

        ByteArrayOutputStream output = new ByteArrayOutputStream();
        output.write("%PDF-1.4\n".getBytes(StandardCharsets.US_ASCII));

        List<Integer> offsets = new ArrayList<>();
        offsets.add(0);
        for (byte[] object : objects) {
            offsets.add(output.size());
            output.write(object);
        }

        int xrefStart = output.size();
        int objectCount = objects.size() + 1;
        StringBuilder xref = new StringBuilder();
        xref.append("xref\n0 ").append(objectCount).append("\n");
        xref.append("0000000000 65535 f \n");
        for (int i = 1; i < objectCount; i++) {
            xref.append(String.format("%010d 00000 n \n", offsets.get(i)));
        }
        output.write(xref.toString().getBytes(StandardCharsets.US_ASCII));

        String trailer = "trailer\n<< /Size " + objectCount + " /Root 1 0 R >>\nstartxref\n" + xrefStart + "\n%%EOF";
        output.write(trailer.getBytes(StandardCharsets.US_ASCII));
        return output.toByteArray();
    }

    private static byte[] object(int objectNumber, String body) {
        String text = objectNumber + " 0 obj\n" + body + "\nendobj\n";
        return text.getBytes(StandardCharsets.US_ASCII);
    }

    private static byte[] streamObject(int objectNumber, byte[] streamBytes) {
        String header = objectNumber + " 0 obj\n<< /Length " + streamBytes.length + " >>\nstream\n";
        String footer = "\nendstream\nendobj\n";
        ByteArrayOutputStream output = new ByteArrayOutputStream();
        try {
            output.write(header.getBytes(StandardCharsets.US_ASCII));
            output.write(streamBytes);
            output.write(footer.getBytes(StandardCharsets.US_ASCII));
        } catch (IOException e) {
            throw new IllegalStateException("Unable to write PDF stream", e);
        }
        return output.toByteArray();
    }

    private static String buildContentStream(List<String> lines, boolean firstPage) {
        StringBuilder builder = new StringBuilder();
        builder.append("BT\n");
        builder.append("/F1 10 Tf\n");
        builder.append("1 0 0 1 ").append(LEFT_MARGIN).append(" ").append(PAGE_HEIGHT - TOP_MARGIN).append(" Tm\n");
        for (int i = 0; i < lines.size(); i++) {
            String line = escape(lines.get(i));
            if (i == 0 && firstPage) {
                builder.append("/F1 14 Tf\n");
                builder.append("(").append(line).append(") Tj\n");
                builder.append("/F1 10 Tf\n");
                builder.append("T*\n");
                continue;
            }
            builder.append("(").append(line).append(") Tj\n");
            builder.append("T*\n");
        }
        builder.append("ET\n");
        return builder.toString();
    }

    private static String buildContentStreamWithHeader(List<String> lines, boolean firstPage, String title, String subtitle, int pageNumber, int pageCount) {
        StringBuilder builder = new StringBuilder();
        // We'll position each line explicitly using Tm to avoid relying on T*
        builder.append("BT\n");
        int y = PAGE_HEIGHT - 34;

        // Header band background and accent line are handled by separate drawing commands in the page content stream,
        // but since this is a pure text writer we simulate the layout with spacing and styled text only.
        // Title block
        if (firstPage && title != null && !title.isEmpty()) {
            builder.append("/F1 18 Tf\n");
            builder.append("1 0 0 1 ").append(LEFT_MARGIN).append(" ").append(y).append(" Tm\n");
            builder.append("(").append(escape(sanitize(title))).append(") Tj\n");
            y -= 20;
        }

        if (firstPage && subtitle != null && !subtitle.isEmpty()) {
            builder.append("/F1 11 Tf\n");
            builder.append("1 0 0 1 ").append(LEFT_MARGIN).append(" ").append(y).append(" Tm\n");
            builder.append("(").append(escape(sanitize(subtitle))).append(") Tj\n");
            y -= 16;
        }

        y -= 4;
        builder.append("/F1 10 Tf\n");
        for (int i = 0; i < lines.size(); i++) {
            String line = lines.get(i);
            if (line.startsWith("[TITLE]")) {
                continue;
            }
            if (line.startsWith("[SUBTITLE]")) {
                continue;
            }
            if (line.startsWith("[SECTION]")) {
                String sectionTitle = line.substring("[SECTION]".length());
                if (y <= BOTTOM_MARGIN + 24) {
                    break;
                }
                builder.append("/F1 13 Tf\n");
                builder.append("1 0 0 1 ").append(LEFT_MARGIN).append(" ").append(y).append(" Tm\n");
                builder.append("(").append(escape(sectionTitle)).append(") Tj\n");
                y -= 14;
                builder.append("/F1 10 Tf\n");
                continue;
            }
            if (line.trim().isEmpty()) {
                y -= 6;
                continue;
            }
            if (y <= BOTTOM_MARGIN) {
                break;
            }
            String rendered = escape(line.trim());
            builder.append("1 0 0 1 ").append(LEFT_MARGIN).append(" ").append(y).append(" Tm\n");
            builder.append("(").append(rendered).append(") Tj\n");
            y -= 12;
        }

        // Footer with page number
        builder.append("ET\n");
        builder.append("BT\n");
        builder.append("/F1 9 Tf\n");
        int footerY = BOTTOM_MARGIN - 10;
        if (footerY < 10) footerY = 10;
        builder.append("1 0 0 1 ").append(PAGE_WIDTH - LEFT_MARGIN - 100).append(" ").append(footerY).append(" Tm\n");
        builder.append("(").append("Page " + pageNumber + " of " + pageCount).append(") Tj\n");
        builder.append("ET\n");
        return builder.toString();
    }

    private static List<List<String>> paginate(List<String> lines, int maxLinesPerPage) {
        List<List<String>> pages = new ArrayList<>();
        List<String> current = new ArrayList<>();
        for (String line : lines) {
            if (current.size() >= maxLinesPerPage) {
                pages.add(current);
                current = new ArrayList<>();
            }
            current.add(line);
        }
        if (!current.isEmpty()) {
            pages.add(current);
        }
        if (pages.isEmpty()) {
            pages.add(new ArrayList<String>());
        }
        return pages;
    }

    private static List<Section> parseSections(List<String> lines) {
        List<Section> sections = new ArrayList<>();
        Section current = null;
        for (String rawLine : lines) {
            String line = sanitize(rawLine);
            if (line == null) {
                continue;
            }
            if (line.trim().isEmpty()) {
                continue;
            }
            if (!line.startsWith(" ") && !line.contains(":") && !line.startsWith("-") && !line.startsWith("[")) {
                if (current != null && !current.items.isEmpty()) {
                    sections.add(current);
                }
                current = new Section(line.trim());
                continue;
            }
            if (current == null) {
                current = new Section("Overview");
            }
            current.items.add(line.trim());
        }
        if (current != null && !current.items.isEmpty()) {
            sections.add(current);
        }
        if (sections.isEmpty()) {
            Section overview = new Section("Overview");
            for (String rawLine : lines) {
                String line = sanitize(rawLine);
                if (line != null && !line.trim().isEmpty()) {
                    overview.items.add(line.trim());
                }
            }
            sections.add(overview);
        }
        return sections;
    }

    private static List<String> wrapLine(String line) {
        List<String> wrapped = new ArrayList<>();
        if (line == null || line.isEmpty()) {
            wrapped.add("");
            return wrapped;
        }
        if (line.length() <= MAX_CHARS_PER_LINE) {
            wrapped.add(line);
            return wrapped;
        }

        String[] words = line.split("\\s+");
        StringBuilder current = new StringBuilder();
        for (String word : words) {
            if (current.length() == 0) {
                current.append(word);
            } else if (current.length() + 1 + word.length() <= MAX_CHARS_PER_LINE) {
                current.append(' ').append(word);
            } else {
                wrapped.add(current.toString());
                current.setLength(0);
                current.append(word);
            }
        }
        if (current.length() > 0) {
            wrapped.add(current.toString());
        }
        return wrapped;
    }

    private static String sanitize(String value) {
        if (value == null) {
            return "";
        }
        return value.replace('\t', ' ').replaceAll("[^\\x20-\\x7E]", "?");
    }

    private static String escape(String value) {
        return value.replace("\\", "\\\\").replace("(", "\\(").replace(")", "\\)");
    }

    private static final class Section {
        private final String title;
        private final List<String> items = new ArrayList<>();

        private Section(String title) {
            this.title = title;
        }
    }
}
