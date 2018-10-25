#include "logging.hpp"

QtMsgType level = QtCriticalMsg;
QLoggingCategory WebpageLogging("Webpage", level);
QLoggingCategory SearchDBLogging("SearchDB", QtDebugMsg);

QLoggingCategory GlobalLogging("Global", level);

QLoggingCategory FileLogging("File", level);

QLoggingCategory CrawlerLogging("Crawler", QtDebugMsg);
QLoggingCategory CrawlerRuleLogging("CrawlerRule", level);
QLoggingCategory CrawlerRuleTableLogging("CrawlerRuleTable", level);

QLoggingCategory MacroLogging("Macro", level);

QLoggingCategory ControllerLogging("Controller", QtInfoMsg);

