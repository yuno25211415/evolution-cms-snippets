<?php
/**
 * GetSelectionLabelTv
 *
 * リソースの選択肢のあるテンプレート変数で選択中の値の項目名を取得するスニペット。
 *
 * @category   snippet
 * @version    0.2.0
 * @license    GNU General Public License (GPL), https://www.gnu.org/licenses/gpl-3.0.html
 * @author     Yu.No (https://github.com/yuno25211415)
 * @lastupdate 2026/09/08
 * @internal @properties &
 * @internal @modx_category Custom
 * @internal @installset base, sample
 * @param string &tvName 対象のテンプレート変数名
 * @param string &searchVal 検索する値
 * @param string &docId 対象のリソースID（省略した場合は現在のリソースID）
 * @param string &delimiter 選択肢間の区切り文字
 * @param string &outDelimiter 出力するラベルで複数ある場合の区切り文字
 * @param string &tpl 出力するラベルのHTMLテンプレート
 * @param string &outerTpl 囲う外側のHTMLテンプレート
 * @example [[GetSelectionLabelTv? &tvName=`tags` &searchVal=`[*tags*]`]]
 * @example [[GetSelectionLabelTv? &docId=`3` &tvName=`tags` &searchVal=`[*tags*]`]]
 */

// パラメーターの初期設定
if (!isset($docId)) $docId = $modx->documentIdentifier;
if (!isset($delimiter)) $delimiter = '||';
if (!isset($outDelimiter)) $outDelimiter = ',';
if (!isset($tpl)) $tpl = '@CODE:[+label+]';
if (!isset($outerTpl)) $outerTpl = '@CODE:[+wrap+]';

if (!isset($tvName) || !isset($searchVal)) return '';

$tv = evo()->getTemplateVar($tvName, 'elements', $docId);

if (!$tv) return '';

$searchVals = explode(',', $searchVal);

$matchTv = [];
foreach ($searchVals as $searchVal) {
	$matchTv = array_merge($matchTv, array_filter(explode($delimiter, $tv['elements']), fn ($x) => in_array($searchVal, explode('==', $x))));
}

// evo()->addLog('テンプレート変数['.$tvName.']: '.$docId, [
// 	'tvName'    => $tvName,
// 	'searchVal' => $searchVal,
// 	'matchTv'   => $matchTv
// ]);

if (count($matchTv) == 0) return '';

$labels = array_reduce($matchTv, function ($result, $val) use ($tpl) {
	$label = explode('==', $val)[0];

	$placeholders = [
		'label' => $label
	];

	$result[] = (preg_match('/^@CODE:/', $tpl) ?
		evo()->parseText(preg_replace('/^@CODE:/', '', $tpl), $placeholders) :
		evo()->parseChunk($tpl, $placeholders, '[+', '+]'));

	return $result;
}, []);

$out = count($labels) > 0 ? implode($outDelimiter, $labels) : '';

// プレースホルダーの初期設定
$placeholder = [
	'wrap' => $out
];

// アウターHTMLを生成し出力
return empty($out) ? '' : (preg_match('/^@CODE:/', $outerTpl) ?
	$modx->parseText(preg_replace('/^@CODE:/', '', $outerTpl), $placeholder) :
	$modx->parseChunk($outerTpl, $placeholder, '[+', '+]'));
