<?php
/**
 * Copyright (c) 2021+ furplag (https://github.com/furplag)
 * 
 * Permission is hereby granted, free of charge, to any person obtaining a copy
 * of this software and associated documentation files (the "Software"), to deal
 * in the Software without restriction, including without limitation the rights
 * to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
 * copies of the Software, and to permit persons to whom the Software is
 * furnished to do so, subject to the following conditions:
 * 
 * The above copyright notice and this permission notice shall be included in all
 * copies or substantial portions of the Software.
 * 
 * THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
 * IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
 * FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
 * AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
 * LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
 * OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
 * SOFTWARE.
 */

/**
 * Do work faster, do more easier .
 * usage:
 * 1. declare, like that : `<?php $_ = \Furplag\Sandbox\expr; ?>`;
 * 2. feel free just writing an expression into quoted literals .
 *    "<div>{$_(is_array($maybeAnArray) ? implode('</div><div>', $maybeAnArray) : $maybeAnArray)}</div>";
 *
 * @author furplag<furplag@users.noreply.github.com> 2021
 */
namespace Furplag\Sandbox {
  const expr = __NAMESPACE__ . '\expr';

  /**
   * expans an expression with identity function .
   *
   * @param  mixed $misterio
   * @return mixed $misterio meant a "{$mysterio}"
   */
  function expr($misterio) {
    return $misterio;
  }
}
