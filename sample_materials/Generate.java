

import java.io.FileOutputStream;
import com.psm.elearning.util.SimplePdfWriter;
import java.util.Arrays;
import java.io.File;

public class Generate {
    public static void main(String[] args) throws Exception {
        File dir = new File("c:/Users/ACER/Desktop/FYP/elearning/PSME/sample_materials");
        if (!dir.exists()) dir.mkdirs();

        writePdf("Web_Development_Cheat_Sheet.pdf", "Web Development Cheat Sheet", "Advanced Web Development", Arrays.asList(
            "[SECTION]React Hooks", "A function that lets you hook into React state.",
            "[SECTION]Backend Routing", "Express.js is used for backend routing.",
            "[SECTION]CSS Flexbox", "Used for aligning elements within a container."
        ));

        writePdf("Cloud_Computing_Guide.pdf", "Cloud Computing Fundamentals Guide", "Cloud Computing Architecture", Arrays.asList(
            "[SECTION]AWS", "Amazon Web Services provides scalable computing capacity.",
            "[SECTION]EC2", "Elastic Compute Cloud for virtual servers.",
            "[SECTION]Benefits", "High scalability and pay-as-you-go pricing."
        ));

        writePdf("SEO_Strategy_Playbook.pdf", "SEO and Content Strategy Playbook", "Digital Marketing Strategy", Arrays.asList(
            "[SECTION]SEO", "Search Engine Optimization.",
            "[SECTION]Content Marketing", "Attract and retain a defined audience.",
            "[SECTION]Bounce Rate", "Percentage of users who leave without clicking."
        ));

        writePdf("Scrum_Framework_Guidelines.pdf", "Scrum Framework Guidelines", "Agile Project Management", Arrays.asList(
            "[SECTION]Sprints", "Typical length is 2-4 weeks.",
            "[SECTION]Product Owner", "Responsible for prioritizing the product backlog.",
            "[SECTION]Daily Standup", "Synchronize activities and create a plan."
        ));

        writePdf("Design_Thinking_Framework.pdf", "Design Thinking Framework", "UI/UX Principles and Prototyping", Arrays.asList(
            "[SECTION]UI vs UX", "UI is visual, UX is the overall experience.",
            "[SECTION]Figma", "Common tool for high-fidelity prototyping.",
            "[SECTION]Wireframe", "Low-fidelity visual representation."
        ));

        writePdf("Color_Theory_Handbook.pdf", "Color Theory and Typography Handbook", "Graphic Design Fundamentals", Arrays.asList(
            "[SECTION]Primary Colors", "Red, Yellow, Blue.",
            "[SECTION]Kerning", "The space between individual characters.",
            "[SECTION]Negative Space", "Empty space around the subject."
        ));

        System.out.println("PDFs generated successfully.");
    }

    private static void writePdf(String filename, String title, String subtitle, java.util.List<String> lines) throws Exception {
        byte[] pdfBytes = SimplePdfWriter.writeBrandedPdf(title, subtitle, lines);
        try (FileOutputStream fos = new FileOutputStream("c:/Users/ACER/Desktop/FYP/elearning/PSME/sample_materials/" + filename)) {
            fos.write(pdfBytes);
        }
    }
}
