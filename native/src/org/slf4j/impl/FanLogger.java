//
// Copyright 2012 leafclick s.r.o. <info@leafclick.com>
//
// Licensed under the Apache License, Version 2.0 (the "License");
// you may not use this file except in compliance with the License.
// You may obtain a copy of the License at
//
//     http://www.apache.org/licenses/LICENSE-2.0
//
// Unless required by applicable law or agreed to in writing, software
// distributed under the License is distributed on an "AS IS" BASIS,
// WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
// See the License for the specific language governing permissions and
// limitations under the License.
//

package org.slf4j.impl;

import fan.sys.*;

import org.slf4j.Logger;
import org.slf4j.helpers.FormattingTuple;
import org.slf4j.helpers.MarkerIgnoringBase;
import org.slf4j.helpers.MessageFormatter;

public class FanLogger extends MarkerIgnoringBase implements Logger {

    private Log fanLogger;

    public FanLogger(Log fanLogger) {
        this.fanLogger = fanLogger;
    }

    private void log(LogLevel level, String message, Throwable t) {
        if (! isLevelEnabled(level)) {
            return;
        }

        fanLogger.log(LogRec.make(DateTime.now(), level, fanLogger.name(), message, Err.make(t)));

    }

    private void formatAndLog(LogLevel level, String format, Object arg1,
                              Object arg2) {
        if (! isLevelEnabled(level)) {
            return;
        }
        FormattingTuple tp = MessageFormatter.format(format, arg1, arg2);
        log(level, tp.getMessage(), tp.getThrowable());
    }

    private void formatAndLog(LogLevel level, String format, Object[] argArray) {
        if (! isLevelEnabled(level)) {
            return;
        }
        FormattingTuple tp = MessageFormatter.arrayFormat(format, argArray);
        log(level, tp.getMessage(), tp.getThrowable());
    }

    protected boolean isLevelEnabled(LogLevel level) {
        return fanLogger.enabled(level);
    }

    public boolean isTraceEnabled() {
        return isLevelEnabled(LogLevel.debug);
    }

    public void trace(String msg) {
        log(LogLevel.debug, msg, null);
    }

    public void trace(String format, Object param1) {
        formatAndLog(LogLevel.debug, format, param1, null);
    }

    public void trace(String format, Object param1, Object param2) {
        formatAndLog(LogLevel.debug, format, param1, param2);
    }

    public void trace(String format, Object[] argArray) {
        formatAndLog(LogLevel.debug, format, argArray);
    }

    public void trace(String msg, Throwable t) {
        log(LogLevel.debug, msg, t);
    }

    public boolean isDebugEnabled() {
        return isLevelEnabled(LogLevel.debug);
    }

    public void debug(String msg) {
        log(LogLevel.debug, msg, null);
    }

    public void debug(String format, Object param1) {
        formatAndLog(LogLevel.debug, format, param1, null);
    }

    public void debug(String format, Object param1, Object param2) {
        formatAndLog(LogLevel.debug, format, param1, param2);
    }

    public void debug(String format, Object[] argArray) {
        formatAndLog(LogLevel.debug, format, argArray);
    }

    public void debug(String msg, Throwable t) {
        log(LogLevel.debug, msg, t);
    }

    public boolean isInfoEnabled() {
        return isLevelEnabled(LogLevel.info);
    }

    public void info(String msg) {
        log(LogLevel.info, msg, null);
    }

    public void info(String format, Object arg) {
        formatAndLog(LogLevel.info, format, arg, null);
    }

    public void info(String format, Object arg1, Object arg2) {
        formatAndLog(LogLevel.info, format, arg1, arg2);
    }

    public void info(String format, Object[] argArray) {
        formatAndLog(LogLevel.info, format, argArray);
    }

    public void info(String msg, Throwable t) {
        log(LogLevel.info, msg, t);
    }

    public boolean isWarnEnabled() {
        return isLevelEnabled(LogLevel.warn);
    }

    public void warn(String msg) {
        log(LogLevel.warn, msg, null);
    }

    public void warn(String format, Object arg) {
        formatAndLog(LogLevel.warn, format, arg, null);
    }

    public void warn(String format, Object arg1, Object arg2) {
        formatAndLog(LogLevel.warn, format, arg1, arg2);
    }

    public void warn(String format, Object[] argArray) {
        formatAndLog(LogLevel.warn, format, argArray);
    }

    public void warn(String msg, Throwable t) {
        log(LogLevel.warn, msg, t);
    }

    public boolean isErrorEnabled() {
        return isLevelEnabled(LogLevel.err);
    }

    public void error(String msg) {
        log(LogLevel.err, msg, null);
    }

    public void error(String format, Object arg) {
        formatAndLog(LogLevel.err, format, arg, null);
    }

    public void error(String format, Object arg1, Object arg2) {
        formatAndLog(LogLevel.err, format, arg1, arg2);
    }

    public void error(String format, Object[] argArray) {
        formatAndLog(LogLevel.err, format, argArray);
    }

    public void error(String msg, Throwable t) {
        log(LogLevel.err, msg, t);
    }
}
