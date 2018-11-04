#include "logging.hpp"

QtMsgType release = QtCriticalMsg;
QtMsgType debug = QtDebugMsg;

QLoggingCategory WebpageLogging("Webpage", release);
QLoggingCategory SearchDBLogging("SearchDB", release);

QLoggingCategory GlobalLogging("Global", release);

QLoggingCategory FileLogging("File", release);

QLoggingCategory CrawlerLogging("Crawler", release);
QLoggingCategory CrawlerRuleLogging("CrawlerRule", release);
QLoggingCategory CrawlerRuleTableLogging("CrawlerRuleTable", release);

QLoggingCategory MacroLogging("Macro", release);

QLoggingCategory ControllerLogging("Controller", QtInfoMsg);

