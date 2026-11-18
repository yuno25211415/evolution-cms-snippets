<?php
/**
 * IterateValues
 *
 * 文字列を分割して繰り返すスニペット。
 *
 * @category   snippet
 * @version    1.0.0
 * @license    GNU General Public License (GPL), https://www.gnu.org/licenses/gpl-3.0.html
 * @author     Yu.No (https://github.com/yuno25211415)
 * @lastupdate 2026/11/18
 * @internal @properties &
 * @internal @modx_category Custom
 * @internal @installset base, sample
 * @param string &value 対象の文字列
 * @param string &delimiter 選択肢間の区切り文字
 * @param string &outerTpl 囲う外側のHTMLテンプレート
 * @param string &rowTpl 出力するラベルのHTMLテンプレート
 * @example [[IterateValues? &value=`[*keywords*]` &outerTpl=`@CODE:<ul>[+wrap+]</ul>` &rowTpl=`@CODE:<li>[+value+]</li>`]]
 */

// パラメーターの初期設定
if (!isset($delimiter)) $delimiter = ',';
if (!isset($outerTpl)) $outerTpl = '@CODE:[+wrap+]';
if (!isset($rowTpl)) $rowTpl = '@CODE:[+value+]';

if (!isset($value) || empty($value)) return '';

$values = explode($delimiter, $value);

$out = '';

foreach ($values as $i => $val) {
	$placeholders = [
		'index' => $i,
		'value' => $val
	];

	$out .= (preg_match('/^@CODE:/', $rowTpl) ?
		$modx->parseText(preg_replace('/^@CODE:/', '', $rowTpl), $placeholders) :
		$modx->parseChunk($rowTpl, $placeholders, '[+', '+]'));
}

// プレースホルダーの初期設定
$placeholder = [
	'wrap'  => $out,
	'count' => count($values)
];

// アウターHTMLを生成し出力
return empty($out) ? '' : (preg_match('/^@CODE:/', $outerTpl) ?
	$modx->parseText(preg_replace('/^@CODE:/', '', $outerTpl), $placeholder) :
	$modx->parseChunk($outerTpl, $placeholder, '[+', '+]'));