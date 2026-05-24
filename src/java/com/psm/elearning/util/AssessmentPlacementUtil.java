package com.psm.elearning.util;

import java.util.regex.Matcher;
import java.util.regex.Pattern;

public final class AssessmentPlacementUtil {

    private static final Pattern PLACEMENT_PATTERN =
            Pattern.compile("\\[\\[placement:(final|afterMaterial=(\\d+))\\]\\]");

    private static final Pattern LEGACY_PLACEMENT_PATTERN =
            Pattern.compile("##PLACEMENT:(final|afterMaterial:(\\d+))##");

    private AssessmentPlacementUtil() {
    }

    public static class Placement {
        public final String type;
        public final Integer materialId;

        public Placement(String type, Integer materialId) {
            this.type = type;
            this.materialId = materialId;
        }
    }

    public static Placement parsePlacement(String instructions) {
        if (instructions == null || instructions.isEmpty()) {
            return new Placement("final", null);
        }
        Matcher matcher = PLACEMENT_PATTERN.matcher(instructions);
        if (matcher.find()) {
            String token = matcher.group(1);
            if (token != null && token.startsWith("afterMaterial=")) {
                String idText = matcher.group(2);
                Integer materialId = safeParseInt(idText);
                return new Placement("afterMaterial", materialId);
            }
            return new Placement("final", null);
        }
        // Try legacy ##PLACEMENT:...## format
        Matcher legacyMatcher = LEGACY_PLACEMENT_PATTERN.matcher(instructions);
        if (legacyMatcher.find()) {
            String token = legacyMatcher.group(1);
            if (token != null && token.startsWith("afterMaterial:")) {
                String idText = legacyMatcher.group(2);
                Integer materialId = safeParseInt(idText);
                return new Placement("afterMaterial", materialId);
            }
            return new Placement("final", null);
        }
        return new Placement("final", null);
    }

    public static String stripPlacement(String instructions) {
        if (instructions == null || instructions.isEmpty()) {
            return instructions;
        }
        String cleaned = PLACEMENT_PATTERN.matcher(instructions).replaceAll("").trim();
        cleaned = LEGACY_PLACEMENT_PATTERN.matcher(cleaned).replaceAll("").trim();
        return cleaned.isEmpty() ? null : cleaned;
    }

    public static String applyPlacement(String instructions, String placementKey) {
        String cleaned = stripPlacement(instructions);
        if (placementKey == null || placementKey.trim().isEmpty() || "final".equalsIgnoreCase(placementKey)) {
            return appendMarker(cleaned, "final");
        }
        if (placementKey.startsWith("material:")) {
            Integer materialId = safeParseInt(placementKey.substring("material:".length()));
            if (materialId != null) {
                return appendMarker(cleaned, "afterMaterial=" + materialId);
            }
        }
        return appendMarker(cleaned, "final");
    }

    public static String toPlacementKey(Placement placement) {
        if (placement == null) {
            return "final";
        }
        if ("afterMaterial".equals(placement.type) && placement.materialId != null) {
            return "material:" + placement.materialId;
        }
        return "final";
    }

    private static Integer safeParseInt(String text) {
        if (text == null) return null;
        try {
            return Integer.parseInt(text.trim());
        } catch (NumberFormatException e) {
            return null;
        }
    }

    private static String appendMarker(String cleaned, String markerValue) {
        String marker = "[[placement:" + markerValue + "]]";
        if (cleaned == null || cleaned.trim().isEmpty()) {
            return marker;
        }
        return cleaned.trim() + "\n" + marker;
    }
}
