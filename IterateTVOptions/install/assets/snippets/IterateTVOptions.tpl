<?php
/**
 * IterateTVOptions
 *
 * テンプレート変数の選択肢を繰り返すスニペット。
 *
 * @category   snippet
 * @version    0.1.1
 * @license    GNU General Public License (GPL), https://www.gnu.org/licenses/gpl-3.0.html
 * @author     Yu.No (https://github.com/yuno25211415)
 * @lastupdate 2026/07/27
 * @internal @properties &
 * @internal @modx_category Custom
 * @internal @installset base, sample
 * @param string &tvName 対象となるテンプレート変数名
 * @param string &delimiter 選択肢間の区切り文字
 * @param string &outerTpl アイテムを囲う外側のHTMLテンプレート
 * @param string &rowTpl 繰り返すアイテムのHTMLテンプレート
 * @example [[IterateTVOptions? &tvName=`tags`]]
 */

// パラメーターの初期設定
if (!isset($delimiter)) $delimiter = '||';
if (!isset($outerTpl)) $outerTpl = '@CODE:<ul>[+wrap+]</ul>';
if (!isset($rowTpl)) $rowTpl = '@CODE:<li>[+label+]</li>';

if (!isset($tvName) || empty($tvName)) return '';

$snippetName = evo()->getSnippetName();

$data = \DB::table('site_tmplvars')->where('name', '=', $tvName)->first();

if (!$data) {
	evo()->addLog($snippetName, '対象のテンプレート変数が見つかりませんでした。：'.$tvName, 3);
	return '';
};

$tvOpt = $data->elements;
if (preg_match('/^@EVAL /', $tvOpt)) {
	$tvOpt = eval(preg_replace('/^@EVAL /', '', $tvOpt));
}

$elems = explode($delimiter, $tvOpt);

$html = '';

foreach ($elems as $i => $elem) {
	list($label, $value) = explode('==', $elem);

	evo()->addLog($snippetName.':element: '.$label, [$label, $value, gettype($value)]);

	// プレースホルダーの初期設定
	$placeholder = [
		'tvName' => $tvName,
		'index'  => $i,
		'label'  => $label,
		'value'  => $value === null ? $label : $value
	];

	// HTMLを生成
	$html .= preg_match('/^@CODE:/', $rowTpl) ?
		$modx->parseText(preg_replace('/^@CODE:/', '', $rowTpl), $placeholder) :
		$modx->parseChunk($rowTpl, $placeholder, '[+', '+]');
}

// プレースホルダーの初期設定
$placeholder = [
	'tvName' => $tvName,
	'wrap'   => $html
];

// アウターHTMLを生成し出力
return empty($html) ? '' : (preg_match('/^@CODE:/', $outerTpl) ?
	$modx->parseText(preg_replace('/^@CODE:/', '', $outerTpl), $placeholder) :
	$modx->parseChunk($outerTpl, $placeholder, '[+', '+]'));
