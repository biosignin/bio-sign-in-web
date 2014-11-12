package eu.inn.wssign.controller.utils;

import org.apache.log4j.Logger;
import org.apache.log4j.Priority;

public class AuditLogger {

	private static Logger logger = Logger.getLogger("AUDIT");

	public static void LOG(Priority priority, Object message) {
		logger.log(priority, message);
	}
}
