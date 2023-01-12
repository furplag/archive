/*
 * Copyright (C) 2022+ furplag (https://github.com/furplag)
 *
 * Licensed under the Apache License, Version 2.0 (the "License");
 * you may not use this file except in compliance with the License.
 * You may obtain a copy of the License at
 *
 *         http://www.apache.org/licenses/LICENSE-2.0
 *
 * Unless required by applicable law or agreed to in writing, software
 * distributed under the License is distributed on an "AS IS" BASIS,
 * WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 * See the License for the specific language governing permissions and
 * limitations under the License.
 */
'use strict';

/**
 * Unbending Promise is useful for retrying an operation that may sometimes fail for transient reasons .
 * it can be used to stop the retry loop whenever you want and exit the loop gracefully before the limit is reached . 
 * this can be achieved by setting the 'abort' parameter to true .
 *
 * @function unbendingPromise
 * @param {Function} fn - a function to retry, it should return a promise that resolves to a boolean indicating success or failure .
 * @param {string} [beacon] - an optional identifier to identify the process being retried
 * @param {number} [limit=100] - the maximum number of attempts to retry the function before it is rejected
 * @param {number} [delay=100] - the delay in milliseconds between retries
 * @param {boolean} [abort=false] - a flag that when set to true, will cause the promise to reject immediately .
 * 
 * @returns {Promise} - a promise that will resolve when the provided function returns true . the promise will retry with a delay 
 * if the provided function returns false, and it will be rejected if the limit is reached or the abort flag is true .
 */
function unbendingPromise(fn = () => Promise.resolve(true), beacon, limit = 100, delay = 100, abort = false) {
  let counter = limit;
  const attempt = (resolve, reject) => {
    if (counter === 0 || abort) {
      return reject(`🚧 limit reached: ${beacon || 'a process'} (limit: ${limit}) .`);
    }
    fn().then(result => {
      if (result) {
          return resolve(result);
      } else {
          counter--;
          console.debug(`⌛ ${beacon || 'processing'}${limit < 0 ? '' : ` ( ${limit - counter} / ${limit} )`} ... `);
          return setTimeout(() => attempt(resolve, reject), delay);
      }
    }).catch(error => reject(error));
  };

  return new Promise(attempt);
}

export { unbendingPromise }
