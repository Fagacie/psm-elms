package com.psm.elearning.async;

import com.psm.elearning.dao.CourseDAO;
import com.psm.elearning.dao.CourseDAOImpl;
import com.psm.elearning.model.Course;
import com.psm.elearning.util.CloudinaryUtil;

import java.util.logging.Level;
import java.util.logging.Logger;

/**
 * Asynchronous task that uploads a course banner image to Cloudinary and
 * updates the course record with the resulting URL once the upload completes.
 *
 * <p>Spawn via a daemon thread so the upload does not block the HTTP request:
 * <pre>
 *   Thread t = new Thread(new CloudinaryUploadTask(courseId, fileBytes, fileName));
 *   t.setDaemon(true);
 *   t.start();
 * </pre>
 *
 * <p>The {@code BannerUploadStatus} column is updated to reflect the outcome:
 * <ul>
 *   <li>{@code "pending"}  – set before the task starts (by the caller)</li>
 *   <li>{@code "uploaded"} – set on success</li>
 *   <li>{@code "failed"}   – set when Cloudinary returns null or throws</li>
 * </ul>
 */
public class CloudinaryUploadTask implements Runnable {

    private static final Logger LOGGER = Logger.getLogger(CloudinaryUploadTask.class.getName());

    private final int    courseId;
    private final byte[] fileBytes;
    private final String fileName;

    /**
     * @param courseId  ID of the course whose banner is being uploaded
     * @param fileBytes raw bytes of the image file
     * @param fileName  original file name (used to derive the extension / public ID)
     */
    public CloudinaryUploadTask(int courseId, byte[] fileBytes, String fileName) {
        this.courseId  = courseId;
        this.fileBytes = fileBytes;
        this.fileName  = fileName;
    }

    @Override
    public void run() {
        LOGGER.log(Level.INFO,
                "[ASYNC] Starting banner upload for courseId={0}, file={1}",
                new Object[]{courseId, fileName});

        CourseDAO courseDAO = new CourseDAOImpl();

        try {
            String url = CloudinaryUtil.uploadFile(
                    fileBytes,
                    fileName,
                    CloudinaryUtil.getCourseBannersFolder(),
                    "image");

            if (url == null || url.trim().isEmpty()) {
                LOGGER.log(Level.WARNING,
                        "[ASYNC] Banner upload returned null for courseId={0}. Marking as failed.",
                        courseId);
                courseDAO.updateBannerUploadStatus(courseId, Course.BANNER_STATUS_FAILED);
                return;
            }

            boolean bannerUpdated = courseDAO.updateCourseBanner(courseId, url);
            boolean statusUpdated = courseDAO.updateBannerUploadStatus(courseId, Course.BANNER_STATUS_UPLOADED);

            if (bannerUpdated && statusUpdated) {
                LOGGER.log(Level.INFO,
                        "[ASYNC] Banner upload complete for courseId={0}: {1}",
                        new Object[]{courseId, url});
            } else {
                LOGGER.log(Level.WARNING,
                        "[ASYNC] Banner uploaded to Cloudinary but DB update failed for courseId={0}",
                        courseId);
            }

        } catch (Exception e) {
            LOGGER.log(Level.SEVERE,
                    "[ASYNC] Unexpected error during banner upload for courseId=" + courseId, e);
            try {
                courseDAO.updateBannerUploadStatus(courseId, Course.BANNER_STATUS_FAILED);
            } catch (Exception ex) {
                LOGGER.log(Level.WARNING,
                        "[ASYNC] Could not update banner status to failed for courseId=" + courseId, ex);
            }
        }
    }
}
